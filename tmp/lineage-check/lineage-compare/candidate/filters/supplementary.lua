-- supplementary.lua (v5)
-- Defer supplement to end (after citeproc), robust lists page (Markdown or LaTeX floats),
-- one float per page, no duplicate header.

local utils = require 'pandoc.utils'
local stringify = utils.stringify

local collected = {}

local function is_supp_div (el)
  if el.t ~= "Div" then return false end
  local classes = el.attr and el.attr.classes or {}
  for _, c in ipairs(classes) do
    if c == "supplementary" then return true end
  end
  return false
end

local function drop_leading_supp_header(blocks)
  if #blocks == 0 then return blocks end
  local b = blocks[1]
  if b.t == "Header" then
    local txt = stringify(b.content or {}):gsub("^%s+", ""):gsub("%s+$", "")
    local low = string.lower(txt)
    if low == "supplementary materials" or low == "supplementary material" or low == "supplementary" then
      table.remove(blocks, 1)
    end
  end
  return blocks
end

function Div (el)
  if is_supp_div(el) then
    local cleaned = drop_leading_supp_header(pandoc.List(el.content))
    table.insert(collected, pandoc.Div(cleaned, el.attr))
    return {}
  end
  return nil
end

-- capture \caption{...} and \label{...} within LaTeX raw blocks
local function parse_raw_latex_for_floats(raw)
  local figs, tabs = {}, {}
  -- match environments (simple patterns; good enough for common cases)
  for env, body in raw:gmatch("\\begin%s*{%s*(figure)%s*}([\\%w%W]-)\\end%s*{%s*figure%s*}") do
    local cap = body:match("\\caption%s*{%s*(.-)%s*}") or ""
    local id = body:match("\\label%s*{%s*(.-)%s*}") or ""
    table.insert(figs, {caption = cap, id = id})
  end
  for env, body in raw:gmatch("\\begin%s*{%s*(table)%s*}([\\%w%W]-)\\end%s*{%s*table%s*}") do
    local cap = body:match("\\caption%s*{%s*(.-)%s*}") or ""
    local id = body:match("\\label%s*{%s*(.-)%s*}") or ""
    table.insert(tabs, {caption = cap, id = id})
  end
  -- also capture \captionof{figure}{...}\label{...}
  for cap, id in raw:gmatch("\\captionof%s*{%s*figure%s*}%s*{%s*(.-)%s*}.-\\label%s*{%s*(.-)%s*}") do
    table.insert(figs, {caption = cap or "", id = id or ""})
  end
  for cap, id in raw:gmatch("\\captionof%s*{%s*table%s*}%s*{%s*(.-)%s*}.-\\label%s*{%s*(.-)%s*}") do
    table.insert(tabs, {caption = cap or "", id = id or ""})
  end
  return figs, tabs
end

local function collect_items(blocks)
  local figs, tabs = {}, {}
  local function add_fig(caption, id) table.insert(figs, {caption = caption or "", id = id or ""}) end
  local function add_tab(caption, id) table.insert(tabs, {caption = caption or "", id = id or ""}) end

  local function caption_to_text(c) return stringify(c or {}) end

  local function walk(el)
    if type(el) ~= 'table' then return end
    if el.t == "Figure" then
      local cap = ""
      if el.caption then
        if el.caption.long then cap = caption_to_text(el.caption.long) else cap = caption_to_text(el.caption) end
      end
      local id = el.identifier or (el.attr and el.attr.identifier) or ""
      add_fig(cap, id)
    elseif el.t == "Para" and el.content and #el.content == 1 and el.content[1].t == "Image" then
      local img = el.content[1]
      add_fig(caption_to_text(img.caption), (img.attr and img.attr.identifier) or "")
    elseif el.t == "Image" then
      add_fig(caption_to_text(el.caption), (el.attr and el.attr.identifier) or "")
    elseif el.t == "Table" then
      local cap = ""
      if el.caption then
        if el.caption.long then cap = caption_to_text(el.caption.long) else cap = caption_to_text(el.caption) end
      end
      add_tab(cap, (el.attr and el.attr.identifier) or "")
    elseif el.t == "RawBlock" and el.format and el.format:match("[Ll]a[Tt][Ee][Xx]") then
      local latex = el.text or ""
      local f2, t2 = parse_raw_latex_for_floats(latex)
      for _, x in ipairs(f2) do add_fig(x.caption, x.id) end
      for _, x in ipairs(t2) do add_tab(x.caption, x.id) end
    end
    for k, v in pairs(el) do if type(v) == 'table' then walk(v) end end
  end

  for _, b in ipairs(blocks) do walk(b) end
  return figs, tabs
end

local function with_pagebreaks_for_floats(blocks)
  local out = pandoc.List{}
  for _, b in ipairs(blocks) do
    local isFloat = (b.t == "Figure") or (b.t == "Table") or
      (b.t == "Para" and b.content and #b.content == 1 and b.content[1].t == "Image") or
      (b.t == "RawBlock" and b.format and b.format:match("[Ll]a[Tt][Ee][Xx]") and
        (b.text:match("\\begin%s*{%s*figure%s*}") or b.text:match("\\begin%s*{%s*table%s*}") or b.text:match("\\captionof%s*{%s*figure%s*}") or b.text:match("\\captionof%s*{%s*table%s*}")))
    if isFloat then
      out:insert(pandoc.RawBlock("latex", "\\clearpage"))
      out:insert(b)
    else
      out:insert(b)
    end
  end
  return out
end

function Pandoc (doc)
  if #collected == 0 then
    return doc
  end

  -- Ensure a clearpage after bibliography if present
  local blocks = pandoc.List(doc.blocks)
  for i = #blocks, 1, -1 do
    local b = blocks[i]
    if b.t == "Div" and b.identifier == "refs" then
      blocks:insert(i + 1, pandoc.RawBlock("latex", "\\clearpage"))
      break
    end
  end

  -- Flatten supplement blocks
  local supp_blocks = pandoc.List{}
  for _, d in ipairs(collected) do
    for _, b in ipairs(d.content) do supp_blocks:insert(b) end
  end

  local figs, tabs = collect_items(supp_blocks)

  -- Build the lists page (prefix titles + optional refs)
  local listBlocks = pandoc.List{}
  if #figs > 0 then
    listBlocks:insert(pandoc.RawBlock("latex", "\\subsection*{List of Supplementary Figures}"))
    for i, f in ipairs(figs) do
      local label = (f.id ~= "" and (" (\\ref{" .. f.id .. "})") or "")
      local line = string.format("\\textbf{Supplementary Figure S%d.} %s%s", i, f.caption or "", label)
      listBlocks:insert(pandoc.RawBlock("latex", line))
      listBlocks:insert(pandoc.Para{})
    end
  end
  if #tabs > 0 then
    listBlocks:insert(pandoc.RawBlock("latex", "\\subsection*{List of Supplementary Tables}"))
    for i, t in ipairs(tabs) do
      local label = (t.id ~= "" and (" (\\ref{" .. t.id .. "})") or "")
      local line = string.format("\\textbf{Supplementary Table S%d.} %s%s", i, t.caption or "", label)
      listBlocks:insert(pandoc.RawBlock("latex", line))
      listBlocks:insert(pandoc.Para{})
    end
  end

  local lists_tex = ""
  if #listBlocks > 0 then
    lists_tex = pandoc.write(pandoc.Pandoc(listBlocks, doc.meta), "latex") .. "\\clearpage\n"
  end
  local paged = with_pagebreaks_for_floats(supp_blocks)
  local supp_tex = pandoc.write(pandoc.Pandoc(paged, doc.meta), "latex")

  local combined = "\\begin{supplementary}\n" .. lists_tex .. supp_tex .. "\\end{supplementary}\n"
  local tail = pandoc.RawBlock("latex", "\\AtEndDocument{\n" .. combined .. "}")
  blocks:insert(tail)

  return pandoc.Pandoc(blocks, doc.meta)
end