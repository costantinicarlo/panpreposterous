
-- backmatter.lua (v3): strict two-column policy for Markdown tables
-- Features:
--  - Div.backmatter (optionally .onecol) -> LaTeX backmatter env (+ optional one/two column toggle)
--  - Div.wide -> full-width block using \begin{wideblock}...\end{wideblock}
--  - Div.onecol -> temporary one-column island, then back to two columns
--  - Div.texinclude with attribute src -> emits \input{<src>}
--  - Table: in twocolumn mode, Markdown tables are SUPPRESSED by default unless
--           they carry class .allowmd (render inline) or .onecol (auto-wrap island).

local is_twocolumn = false
local forbid_md_tables = false  -- default; will set true when twocolumn unless overridden in YAML

local function has_class(el, class)
  for _, c in ipairs(el.classes or {}) do
    if c == class then return true end
  end
  return false
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
  local force_onecol = has_class(tbl, 'onecol') or has_class(tbl, 'long') or has_class(tbl, 'longtable') or has_class(tbl, 'fullwidth')

  if is_twocolumn then
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
                  'or convert to LaTeX and include via \\texttt{\\input\\{...\\}}.}}\\end{center}'
      io.stderr:write('[backmatter.lua] Suppressed a Markdown table in two-column mode. Add {.onecol} or {.allowmd} to override.\\n')
      return { pandoc.RawBlock('latex', msg) }
    end
  end

  -- Default: render table normally
  return nil
end
