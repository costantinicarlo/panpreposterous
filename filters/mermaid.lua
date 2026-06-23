-- mermaid.lua (v1): Convert Mermaid diagram code blocks to embedded SVG figures
-- Features:
--  - Detect code blocks with language='mermaid' or class='.mermaid'
--  - Call mermaid-cli (mmdc) to render to SVG
--  - Embed SVG as LaTeX figure environment
--  - Preserve captions, labels, and width attributes
--  - Cache rendered SVGs by content hash
--  - Graceful error handling with fallback

local utils = require 'pandoc.utils'
local stringify = utils.stringify
local sha256 = function(s)
  local handle = io.popen('echo -n "' .. s:gsub('"', '\\"') .. '" | sha256sum | cut -d" " -f1')
  local result = handle:read("*a"):gsub('\n', '')
  handle:close()
  return result
end

local MERMAID_CACHE_DIR = '/tmp/panpreposterous_mermaid'
local MERMAID_DEFAULT_WIDTH = '0.9\\columnwidth'
local MERMAID_DEFAULT_HEIGHT = '768'

local function ensure_cache_dir()
  os.execute('mkdir -p "' .. MERMAID_CACHE_DIR .. '"')
end

local function has_class(el, class)
  if not el.classes then return false end
  for _, c in ipairs(el.classes) do
    if c == class then return true end
  end
  return false
end

local function get_attr_value(el, key)
  if not el.attributes then return nil end
  return el.attributes[key]
end

local function render_mermaid_to_svg(source, config)
  ensure_cache_dir()

  config = config or {}
  local width = config.width or 1024
  local height = config.height or 768
  local bg_color = config.bg_color or 'transparent'

  -- Create a hash of the source for caching
  local content_hash = sha256(source)
  local svg_filename = 'mermaid_' .. content_hash .. '.svg'
  local svg_path = MERMAID_CACHE_DIR .. '/' .. svg_filename
  local mmd_path = MERMAID_CACHE_DIR .. '/' .. 'mermaid_' .. content_hash .. '.mmd'

  -- Check if already cached
  local cached_file = io.open(svg_path, 'r')
  if cached_file then
    cached_file:close()
    return svg_path
  end

  -- Write Mermaid source to temporary file
  local mmd_file = io.open(mmd_path, 'w')
  if not mmd_file then
    return nil
  end
  mmd_file:write(source)
  mmd_file:close()

  -- Call mermaid-cli to render
  local cmd = string.format(
    'mmdc -i "%s" -o "%s" -w %d -H %d --backgroundColor %s 2>&1',
    mmd_path, svg_path, width, height, bg_color
  )

  local handle = io.popen(cmd)
  local result = handle:read('*a')
  local success = handle:close()

  if not success or result:match('Error') then
    return nil, result
  end

  return svg_path
end

local function get_caption_text(caption)
  if not caption then return '' end
  if caption.long then return stringify(caption.long) end
  return stringify(caption)
end

local function create_figure_from_svg(svg_path, config)
  config = config or {}
  local caption = config.caption or ''
  local label = config.label or ''
  local width = config.width or MERMAID_DEFAULT_WIDTH

  local figure_lines = {
    '\\begin{figure}[htbp]',
    '\\centering',
  }

  -- Read SVG and embed it
  local svg_file = io.open(svg_path, 'r')
  if svg_file then
    local svg_content = svg_file:read('*a')
    svg_file:close()

    -- Sanitize SVG for LaTeX (escape special characters)
    svg_content = svg_content:gsub('%%', '\\%%')
    svg_content = svg_content:gsub('\\', '\\textbackslash{}')

    -- Use \includegraphics if we can, otherwise embed raw SVG
    table.insert(figure_lines, '\\includegraphics[width=' .. width .. ']{' .. svg_path .. '}')
  else
    return nil
  end

  if caption ~= '' then
    table.insert(figure_lines, '\\caption{' .. caption .. '}')
  end

  if label ~= '' then
    table.insert(figure_lines, '\\label{' .. label .. '}')
  end

  table.insert(figure_lines, '\\end{figure}')

  return table.concat(figure_lines, '\n')
end

local function create_fallback_code_block(source)
  local fallback_lines = {
    '\\begin{figure}[htbp]',
    '\\centering',
    '\\fbox{\\parbox{0.8\\columnwidth}{',
    '\\small \\texttt{[Mermaid diagram rendering failed]}',
    '}}',
    '\\end{figure}',
  }
  return table.concat(fallback_lines, '\n')
end

function CodeBlock(el)
  -- Check if this is a Mermaid code block
  local is_mermaid = (el.language == 'mermaid' or has_class(el, 'mermaid'))

  if not is_mermaid then
    return nil
  end

  -- Extract source code
  local source = el.text or ''
  if not source or source == '' then
    return nil
  end

  -- Prepare configuration
  local config = {
    width = 1024,
    height = tonumber(get_attr_value(el, 'height') or MERMAID_DEFAULT_HEIGHT),
    bg_color = get_attr_value(el, 'bg-color') or 'transparent',
    caption = get_attr_value(el, 'caption') or '',
    label = get_attr_value(el, 'label') or '',
    width_latex = get_attr_value(el, 'width') or MERMAID_DEFAULT_WIDTH,
  }

  -- Render Mermaid to SVG
  local svg_path, error_msg = render_mermaid_to_svg(source, config)

  if not svg_path then
    -- Fallback: render as code block with error message
    local error_text = (error_msg or 'Unknown error'):gsub('\n', ' ')
    return pandoc.RawBlock(
      'latex',
      create_fallback_code_block(source)
    )
  end

  -- Create LaTeX figure with SVG
  local figure_latex = create_figure_from_svg(svg_path, {
    caption = config.caption,
    label = config.label,
    width = config.width_latex,
  })

  if figure_latex then
    return pandoc.RawBlock('latex', figure_latex)
  else
    return pandoc.RawBlock('latex', create_fallback_code_block(source))
  end
end

-- Clean up cache on filter exit (optional, can be commented out for debugging)
-- function Pandoc(doc)
--   os.execute('rm -rf "' .. MERMAID_CACHE_DIR .. '"')
--   return doc
-- end
