
-- backmatter.lua (v4): strict two-column policy for Markdown tables
-- Features:
--  - Div.backmatter (optionally .onecol) -> LaTeX backmatter env (+ optional one/two column toggle)
--  - Div.wide -> full-width block using \begin{wideblock}...\end{wideblock}
--  - Div.onecol -> temporary one-column island, then back to two columns
--  - Div.texinclude with attribute src -> emits \input{<src>}
--  - Table: in twocolumn mode, Markdown tables are SUPPRESSED by default unless
--           they carry class .allowmd (render inline), .onecol (auto-wrap island),
--           or .fullwidth/.widetable/.starred (render as table* float).

local is_twocolumn = false
local forbid_md_tables = false  -- default; will set true when twocolumn unless overridden in YAML

local function has_class(el, class)
  for _, c in ipairs(el.classes or {}) do
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

local function strip_trailing_space(s)
  return (s or ''):gsub('%s+$', '')
end

local function latex_for_blocks(blocks)
  if not blocks or #blocks == 0 then return '' end
  local latex = pandoc.write(pandoc.Pandoc(blocks), 'latex')
  latex = strip_trailing_space(latex)
  latex = latex:gsub('\n\n+', '\\\\ ')
  latex = latex:gsub('\n', ' ')
  return latex
end

local function caption_blocks(caption)
  if not caption then return {} end
  if caption.long then return caption.long end
  return caption
end

local function table_identifier(tbl, fallback_attr)
  local attr = tbl.attr or {}
  if attr.identifier and attr.identifier ~= '' then return attr.identifier end
  if fallback_attr and fallback_attr.identifier and fallback_attr.identifier ~= '' then
    return fallback_attr.identifier
  end
  return nil
end

local function column_width_value(width)
  if type(width) == 'number' then return width end
  if type(width) == 'table' then
    if width.t == 'ColWidth' then return width.c end
    if width[1] then return column_width_value(width[1]) end
  end
  return nil
end

local function column_spec(align, width)
  local width_value = column_width_value(width)
  if width_value and width_value > 0 then
    if align == 'AlignRight' then
      return string.format('>{\\RaggedLeft\\arraybackslash}p{%.3f\\linewidth}', width_value)
    end
    if align == 'AlignCenter' then
      return string.format('>{\\Centering\\arraybackslash}p{%.3f\\linewidth}', width_value)
    end
    return string.format('>{\\RaggedRight\\arraybackslash}p{%.3f\\linewidth}', width_value)
  end

  if align == 'AlignRight' then return 'r' end
  if align == 'AlignCenter' then return 'c' end
  return 'l'
end

local function table_colspecs(tbl)
  local specs = {}
  for _, colspec in ipairs(tbl.colspecs or {}) do
    table.insert(specs, column_spec(colspec[1], colspec[2]))
  end
  return table.concat(specs, '@{}')
end

local function softbreak_texttt_content(content)
  local chunk_size = 16
  local out = {}
  local run_length = 0
  local i = 1

  while i <= #content do
    local ch = content:sub(i, i)

    -- Keep escaped two-char sequences (for example \_) intact.
    if ch == '\\' and i < #content then
      local esc = content:sub(i, i + 1)
      table.insert(out, esc)
      if esc == '\\_' then
        table.insert(out, '\\hspace{0pt}')
        run_length = 0
      else
        run_length = run_length + 2
      end
      i = i + 2
    else
      table.insert(out, ch)

      if ch:match('[/%._:%-]') then
        table.insert(out, '\\hspace{0pt}')
        run_length = 0
      else
        run_length = run_length + 1
        if run_length >= chunk_size then
          table.insert(out, '\\hspace{0pt}')
          run_length = 0
        end
      end

      i = i + 1
    end
  end

  return table.concat(out)
end

local function soften_table_cell_latex(latex)
  return (latex:gsub('\\texttt{([^{}]+)}', function(content)
    if #content < 32 then
      return '\\texttt{' .. content .. '}'
    end
    return '\\texttt{' .. softbreak_texttt_content(content) .. '}'
  end))
end

local function cell_latex(cell)
  local latex = latex_for_blocks(cell.contents or cell.content or {})
  return soften_table_cell_latex(latex)
end

local function row_latex(row)
  local cells = {}
  for _, cell in ipairs(row.cells or {}) do
    table.insert(cells, cell_latex(cell))
  end
  return table.concat(cells, ' & ') .. ' \\\\'
end

local function rows_from_head(head)
  return (head and head.rows) or {}
end

local function rows_from_body(body)
  return (body and body.body) or (body and body.rows) or {}
end

local function width_fraction_string(width_value)
  return string.format('%.4f\\textwidth', width_value)
end

local function x_column_spec(align)
  if align == 'AlignRight' then
    return '>{\\RaggedLeft\\arraybackslash}X'
  end
  if align == 'AlignCenter' then
    return '>{\\Centering\\arraybackslash}X'
  end
  return '>{\\RaggedRight\\arraybackslash}X'
end

local function build_tabularx_colspec(tbl)
  local columns = {}
  local specified_total = 0
  local unspecified_count = 0

  for _, colspec in ipairs(tbl.colspecs or {}) do
    local align = colspec[1]
    local width_value = column_width_value(colspec[2])
    if width_value and width_value > 0 then
      table.insert(columns, { align = align, width = width_value })
      specified_total = specified_total + width_value
    else
      table.insert(columns, { align = align, width = nil })
      unspecified_count = unspecified_count + 1
    end
  end

  if #columns == 0 then
    return '>{\\RaggedRight\\arraybackslash}X'
  end

  local target_total = 0.98
  local min_unspecified_share = 0.06
  local available_for_specified = target_total - (unspecified_count * min_unspecified_share)
  if available_for_specified < 0.30 then
    available_for_specified = 0.30
  end

  local scale = 1
  if unspecified_count == 0 then
    if specified_total > target_total then
      scale = target_total / specified_total
    end
  else
    if specified_total > available_for_specified then
      scale = available_for_specified / specified_total
    end
  end

  local specs = {}
  for _, column in ipairs(columns) do
    if column.width then
      table.insert(specs, column_spec(column.align, column.width * scale))
    else
      table.insert(specs, x_column_spec(column.align))
    end
  end

  return table.concat(specs, '@{}')
end

local function render_fullwidth_table(tbl, wrapper_attr)
  local placement = 't'
  local attrs = {}
  if wrapper_attr and wrapper_attr.attributes then
    for k, v in pairs(wrapper_attr.attributes) do attrs[k] = v end
  end
  if tbl.attributes then
    for k, v in pairs(tbl.attributes) do attrs[k] = v end
  end
  if attrs.placement and attrs.placement ~= '' then placement = attrs.placement end

  local id = table_identifier(tbl, wrapper_attr)
  local colspec = build_tabularx_colspec(tbl)

  local lines = {
    '\\begin{table*}[' .. placement .. ']',
    '\\centering'
  }

  local caption = latex_for_blocks(caption_blocks(tbl.caption))
  if caption ~= '' then
    table.insert(lines, '\\caption{' .. caption .. '}')
  end
  if id then
    table.insert(lines, '\\label{' .. id .. '}')
  end

  table.insert(lines, '\\begin{tabularx}{\\textwidth}{@{}' .. colspec .. '@{}}')
  table.insert(lines, '\\toprule')

  local head_rows = rows_from_head(tbl.head)
  for _, row in ipairs(head_rows) do
    table.insert(lines, row_latex(row))
  end
  if #head_rows > 0 then
    table.insert(lines, '\\midrule')
  end

  for _, body in ipairs(tbl.bodies or {}) do
    for _, row in ipairs(rows_from_body(body)) do
      table.insert(lines, row_latex(row))
    end
  end

  local foot_rows = rows_from_head(tbl.foot)
  if #foot_rows > 0 then
    table.insert(lines, '\\midrule')
    for _, row in ipairs(foot_rows) do
      table.insert(lines, row_latex(row))
    end
  end

  table.insert(lines, '\\bottomrule')
  table.insert(lines, '\\end{tabularx}')
  table.insert(lines, '\\end{table*}')

  return { pandoc.RawBlock('latex', table.concat(lines, '\n')) }
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
  if vt == 'table' then
    if v.t == 'MetaBool' then return v.c end
  end
  return default
end

function Meta(m)
  is_twocolumn = meta_bool(m, 'twocolumn', false)
  -- Allow user override via YAML key: forbid_markdown_tables: true/false
  local user_forbid = meta_bool(m, 'forbid_markdown_tables', nil)
  if user_forbid ~= nil then
    forbid_md_tables = user_forbid
  else
    -- Default: if twocolumn is on, forbid markdown tables unless explicitly allowed
    forbid_md_tables = is_twocolumn
  end
  return m
end

function Div(el)
  -- Supplementary content is handled by supplementary.lua; do not apply the
  -- two-column table suppression policy inside it.
  if has_class(el, 'supplementary') then
    return el, false
  end

  -- Full-width table float: ::: {.fullwidth placement="tb"} <markdown table> :::
  if has_any_class(el, { 'fullwidth', 'widetable', 'starred' }) then
    if #el.content == 1 and el.content[1].t == 'Table' then
      return render_fullwidth_table(el.content[1], el.attr)
    end
  end

  -- Allow the documented Div wrapper style to bypass table suppression.
  if has_class(el, 'allowmd') then
    if #el.content == 1 and el.content[1].t == 'Table' then
      return el.content
    end
  end

  -- Long markdown tables keep the historical one-column island behavior.
  if has_any_class(el, { 'long', 'longtable' }) then
    if #el.content == 1 and el.content[1].t == 'Table' then
      local blocks = { pandoc.RawBlock('latex', '\\onecolumn') }
      for _, b in ipairs(el.content) do table.insert(blocks, b) end
      table.insert(blocks, pandoc.RawBlock('latex', '\\twocolumn'))
      return blocks
    end
  end

  -- Backmatter (optionally onecol)
  if has_class(el, 'backmatter') then
    local begin = '\\begin{backmatter}'
    local finish = '\\end{backmatter}'
    if has_class(el, 'onecol') then
      begin = begin .. '\n\\onecolumn'
      finish = '\\twocolumn\n' .. finish
    end
    local blocks = { pandoc.RawBlock('latex', begin) }
    for _, b in ipairs(el.content) do table.insert(blocks, b) end
    table.insert(blocks, pandoc.RawBlock('latex', finish))
    return blocks
  end
  -- Full-width (cuted) block
  if has_class(el, 'wide') then
    local blocks = { pandoc.RawBlock('latex', '\\begin{wideblock}') }
    for _, b in ipairs(el.content) do table.insert(blocks, b) end
    table.insert(blocks, pandoc.RawBlock('latex', '\\end{wideblock}'))
    return blocks
  end
  -- Generic one-column island (works anywhere)
  if has_class(el, 'onecol') then
    local begin = '\\onecolumn'
    local finish = '\\twocolumn'
    local blocks = { pandoc.RawBlock('latex', begin) }
    for _, b in ipairs(el.content) do table.insert(blocks, b) end
    table.insert(blocks, pandoc.RawBlock('latex', finish))
    return blocks
  end
  -- Include external LaTeX file: ::: {.texinclude src="path/to/file.tex"}
  if has_class(el, 'texinclude') then
    local src = (el.attributes and (el.attributes.src or el.attributes.file)) or nil
    if src then
      return { pandoc.RawBlock('latex', '\\input{' .. src .. '}') }
    end
  end
end

function Table(tbl)
  -- Strict policy in two-column mode: suppress Markdown tables unless allowed
  local allow_inline = has_class(tbl, 'allowmd')
  local force_fullwidth = has_any_class(tbl, { 'fullwidth', 'widetable', 'starred' })
  local force_onecol = has_class(tbl, 'onecol') or has_class(tbl, 'long') or has_class(tbl, 'longtable')

  if is_twocolumn then
    if force_fullwidth then
      return render_fullwidth_table(tbl)
    end
    if force_onecol then
      return {
        pandoc.RawBlock('latex', '\\onecolumn'),
        tbl,
        pandoc.RawBlock('latex', '\\twocolumn')
      }
    end
    if forbid_md_tables and not allow_inline then
      -- Visible warning box in the PDF to catch unintended Markdown tables
      local msg = '\\begin{center}\\fbox{\\parbox{.9\\linewidth}{\\textit{Markdown table suppressed in two-column layout.}\\\\' ..
                  'Use class \\texttt{.onecol} to render as a one-column island, ' ..
                  '\\texttt{.fullwidth} for a two-column float, ' ..
                  'or convert to LaTeX and include via \\texttt{\\input\\{...\\}}.}}\\end{center}'
      io.stderr:write('[backmatter.lua] Suppressed a Markdown table in two-column mode. Add {.onecol}, {.fullwidth}, or {.allowmd} to override.\n')
      return { pandoc.RawBlock('latex', msg) }
    end
  end

  -- Default: render table normally
  return nil
end

return {
  { Meta = Meta },
  { traverse = 'topdown', Div = Div, Table = Table }
}
