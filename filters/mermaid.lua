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
local MERMAID_DEFAULT_WIDTH = '0.9\\linewidth'
local MERMAID_DEFAULT_MAX_HEIGHT = '0.35\\textheight'
local MERMAID_DEFAULT_HEIGHT = '768'
local MERMAID_DEFAULT_FLOAT_PLACEMENT = '!htbp'
local MERMAID_TWOCOL_WIDTH = '0.95\\columnwidth'
local MERMAID_TWOCOL_MAX_HEIGHT = '0.30\\textheight'
local MERMAID_TWOCOL_WIDE_WIDTH = '0.95\\textwidth'
local MERMAID_TWOCOL_WIDE_MAX_HEIGHT = '0.42\\textheight'
local MERMAID_TWOCOL_WIDE_PLACEMENT = '!t'
local MERMAID_DEFAULT_THEME = 'base'
local MERMAID_DEFAULT_PRIMARY_COLOR = '#ffffff'
local MERMAID_DEFAULT_PRIMARY_TEXT_COLOR = '#111827'
local MERMAID_DEFAULT_PRIMARY_BORDER_COLOR = '#4b5563'
local MERMAID_DEFAULT_LINE_COLOR = '#4b5563'
local MERMAID_PUPPETEER_CONFIG_PATH =
  os.getenv('PANPREPOSTEROUS_MERMAID_PUPPETEER_CONFIG_PATH')
  or '/opt/panpreposterous/template/mermaid-puppeteer-config.json'
local is_twocolumn = false

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

local function has_any_class(el, classes)
  for _, class in ipairs(classes) do
    if has_class(el, class) then return true end
  end
  return false
end

local function get_attr_value(el, key)
  if not el.attributes then return nil end
  return el.attributes[key]
end

local function json_escape(s)
  s = tostring(s or '')
  s = s:gsub('\\', '\\\\')
  s = s:gsub('"', '\\"')
  s = s:gsub('\n', '\\n')
  s = s:gsub('\r', '\\r')
  s = s:gsub('\t', '\\t')
  return s
end

local function mermaid_config_json(config)
  local theme = config.theme or MERMAID_DEFAULT_THEME
  local primary_color = config.primary_color or MERMAID_DEFAULT_PRIMARY_COLOR
  local primary_text_color = config.primary_text_color or MERMAID_DEFAULT_PRIMARY_TEXT_COLOR
  local primary_border_color = config.primary_border_color or MERMAID_DEFAULT_PRIMARY_BORDER_COLOR
  local line_color = config.line_color or MERMAID_DEFAULT_LINE_COLOR

  return string.format(
    '{"theme":"%s","flowchart":{"htmlLabels":false},"themeVariables":{"primaryColor":"%s","primaryTextColor":"%s","primaryBorderColor":"%s","lineColor":"%s","fontFamily":"TeX Gyre Termes, Times, serif"}}',
    json_escape(theme),
    json_escape(primary_color),
    json_escape(primary_text_color),
    json_escape(primary_border_color),
    json_escape(line_color)
  )
end

local function meta_bool(m, key, default)
  local v = m[key]
  if v == nil then return default end
  local vt = type(v)
  if vt == 'boolean' then return v end
  if vt == 'string' then
    local s = v:lower()
    if s == 'true' then return true end
    if s == 'false' then return false end
    return default
  end
  if vt == 'table' and v.t == 'MetaBool' then
    return v.c
  end
  if pandoc and pandoc.utils and pandoc.utils.type then
    local ptype = pandoc.utils.type(v)
    if ptype == 'MetaBool' then
      return v.c
    end
  end
  return default
end

local function render_mermaid_to_pdf(source, config)
  ensure_cache_dir()

  config = config or {}
  local width = config.width or 1024
  local height = config.height or 768
  local bg_color = config.bg_color or 'transparent'
  local mermaid_config = mermaid_config_json(config)

  -- Create a hash of the source for caching
  local content_hash = sha256(source .. '\n' .. mermaid_config .. '\n' .. bg_color .. '\n' .. tostring(width) .. 'x' .. tostring(height))
  local svg_filename = 'mermaid_' .. content_hash .. '.svg'
  local pdf_filename = 'mermaid_' .. content_hash .. '.pdf'
  local svg_path = MERMAID_CACHE_DIR .. '/' .. svg_filename
  local pdf_path = MERMAID_CACHE_DIR .. '/' .. pdf_filename
  local mmd_path = MERMAID_CACHE_DIR .. '/' .. 'mermaid_' .. content_hash .. '.mmd'
  local config_path = MERMAID_CACHE_DIR .. '/' .. 'mermaid_' .. content_hash .. '.json'

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

    local config_file = io.open(config_path, 'w')
    if not config_file then
      return nil, 'Failed to create temporary Mermaid config file'
    end
    config_file:write(mermaid_config)
    config_file:close()

    -- Call mermaid-cli to render SVG
    local cmd
    if file_exists(MERMAID_PUPPETEER_CONFIG_PATH) then
      cmd = string.format(
        'mmdc -p "%s" -c "%s" -i "%s" -o "%s" -w %d -H %d --backgroundColor %s 2>&1',
        MERMAID_PUPPETEER_CONFIG_PATH, config_path, mmd_path, svg_path, width, height, bg_color
      )
    else
      cmd = string.format(
        'mmdc -c "%s" -i "%s" -o "%s" -w %d -H %d --backgroundColor %s 2>&1',
        config_path, mmd_path, svg_path, width, height, bg_color
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
  local max_height = config.max_height or MERMAID_DEFAULT_MAX_HEIGHT
  local placement = config.placement or MERMAID_DEFAULT_FLOAT_PLACEMENT
  local figure_env = config.figure_env or 'figure'

  local figure_lines = {
    '\\begin{' .. figure_env .. '}[' .. placement .. ']',
    '\\centering',
  }

  if file_exists(pdf_path) then
    table.insert(
      figure_lines,
      '\\includegraphics[width=' .. width .. ',height=' .. max_height .. ',keepaspectratio]{' .. pdf_path .. '}'
    )
  else
    return nil
  end

  if caption ~= '' then
    table.insert(figure_lines, '\\caption{' .. caption .. '}')
  end

  if label ~= '' then
    table.insert(figure_lines, '\\label{' .. label .. '}')
  end

  table.insert(figure_lines, '\\end{' .. figure_env .. '}')

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
  local is_fullwidth = has_any_class(el, { 'fullwidth', 'wide', 'widetable', 'starred' })
  local default_width = MERMAID_DEFAULT_WIDTH
  local default_max_height = MERMAID_DEFAULT_MAX_HEIGHT
  local default_placement = MERMAID_DEFAULT_FLOAT_PLACEMENT
  local figure_env = 'figure'

  if is_twocolumn then
    default_width = MERMAID_TWOCOL_WIDTH
    default_max_height = MERMAID_TWOCOL_MAX_HEIGHT
  end

  if is_fullwidth then
    figure_env = 'figure*'
    default_width = MERMAID_TWOCOL_WIDE_WIDTH
    default_max_height = MERMAID_TWOCOL_WIDE_MAX_HEIGHT
    default_placement = MERMAID_TWOCOL_WIDE_PLACEMENT
  end

  local config = {
    width = 1024,
    height = tonumber(get_attr_value(el, 'height') or MERMAID_DEFAULT_HEIGHT),
    bg_color = get_attr_value(el, 'bg-color') or 'transparent',
    theme = get_attr_value(el, 'theme') or MERMAID_DEFAULT_THEME,
    primary_color = get_attr_value(el, 'primary-color') or MERMAID_DEFAULT_PRIMARY_COLOR,
    primary_text_color = get_attr_value(el, 'primary-text-color') or MERMAID_DEFAULT_PRIMARY_TEXT_COLOR,
    primary_border_color = get_attr_value(el, 'primary-border-color') or MERMAID_DEFAULT_PRIMARY_BORDER_COLOR,
    line_color = get_attr_value(el, 'line-color') or MERMAID_DEFAULT_LINE_COLOR,
    caption = get_attr_value(el, 'caption') or '',
    label = get_attr_value(el, 'label') or '',
    width_latex = get_attr_value(el, 'width') or default_width,
    max_height_latex = get_attr_value(el, 'max-height') or default_max_height,
    placement = get_attr_value(el, 'placement') or default_placement,
    figure_env = figure_env,
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
    max_height = config.max_height_latex,
    placement = config.placement,
    figure_env = config.figure_env,
  })

  if figure_latex then
    return pandoc.RawBlock('latex', figure_latex)
  else
    return pandoc.RawBlock('latex', create_fallback_code_block(source))
  end
end

function Meta(m)
  is_twocolumn = meta_bool(m, 'twocolumn', false)
  return m
end

-- Clean up cache on filter exit (optional, can be commented out for debugging)
-- function Pandoc(doc)
--   os.execute('rm -rf "' .. MERMAID_CACHE_DIR .. '"')
--   return doc
-- end
