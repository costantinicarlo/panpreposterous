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
local MERMAID_PUPPETEER_CONFIG_PATH =
  os.getenv('PANPREPOSTEROUS_MERMAID_PUPPETEER_CONFIG_PATH')
  or '/opt/panpreposterous/template/mermaid-puppeteer-config.json'

local function file_exists(path)
  local f = io.open(path, 'r')
  if f then
    f:close()
    return true
  end
  return false
end

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

local function render_mermaid_to_pdf(source, config)
  ensure_cache_dir()

  config = config or {}
  local width = config.width or 1024
  local height = config.height or 768
  local bg_color = config.bg_color or 'transparent'

  -- Create a hash of the source for caching
  local content_hash = sha256(source)
  local svg_filename = 'mermaid_' .. content_hash .. '.svg'
  local pdf_filename = 'mermaid_' .. content_hash .. '.pdf'
  local svg_path = MERMAID_CACHE_DIR .. '/' .. svg_filename
  local pdf_path = MERMAID_CACHE_DIR .. '/' .. pdf_filename
  local mmd_path = MERMAID_CACHE_DIR .. '/' .. 'mermaid_' .. content_hash .. '.mmd'

  -- Check if already cached as PDF
  if file_exists(pdf_path) then
    return pdf_path
  end

  -- If SVG exists but PDF does not, convert only
  if not file_exists(svg_path) then
    -- Write Mermaid source to temporary file
    local mmd_file = io.open(mmd_path, 'w')
    if not mmd_file then
      return nil, 'Failed to create temporary Mermaid source file'
    end
    mmd_file:write(source)
    mmd_file:close()

    -- Call mermaid-cli to render SVG
    local cmd
    if file_exists(MERMAID_PUPPETEER_CONFIG_PATH) then
      cmd = string.format(
        'mmdc -p "%s" -i "%s" -o "%s" -w %d -H %d --backgroundColor %s 2>&1',
        MERMAID_PUPPETEER_CONFIG_PATH, mmd_path, svg_path, width, height, bg_color
      )
    else
      cmd = string.format(
        'mmdc -i "%s" -o "%s" -w %d -H %d --backgroundColor %s 2>&1',
        mmd_path, svg_path, width, height, bg_color
      )
    end

    local handle = io.popen(cmd)
    local result = handle:read('*a')
    local success = handle:close()

    if not success or result:match('Error') or not file_exists(svg_path) then
      return nil, result
    end
  end

  -- Convert SVG to PDF for reliable XeLaTeX inclusion
  local convert_cmd = string.format(
    'rsvg-convert -f pdf -o "%s" "%s" 2>&1',
    pdf_path, svg_path
  )
  local convert_handle = io.popen(convert_cmd)
  local convert_result = convert_handle:read('*a')
  local convert_success = convert_handle:close()

  if not convert_success or not file_exists(pdf_path) then
    return nil, convert_result
  end

  return pdf_path
end

local function get_caption_text(caption)
  if not caption then return '' end
  if caption.long then return stringify(caption.long) end
  return stringify(caption)
end

local function create_figure_from_pdf(pdf_path, config)
  config = config or {}
  local caption = config.caption or ''
  local label = config.label or ''
  local width = config.width or MERMAID_DEFAULT_WIDTH

  local figure_lines = {
    '\\begin{figure}[htbp]',
    '\\centering',
  }

  if file_exists(pdf_path) then
    table.insert(figure_lines, '\\includegraphics[width=' .. width .. ']{' .. pdf_path .. '}')
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
  local pdf_path, error_msg = render_mermaid_to_pdf(source, config)

  if not pdf_path then
    -- Fallback: render as code block with error message
    local error_text = (error_msg or 'Unknown error'):gsub('\n', ' ')
    return pandoc.RawBlock(
      'latex',
      create_fallback_code_block(source)
    )
  end

  -- Create LaTeX figure with SVG
  local figure_latex = create_figure_from_pdf(pdf_path, {
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
