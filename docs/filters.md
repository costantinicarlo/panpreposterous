# Filter Behavior Contract

## Purpose

This document explains how the Panpreposterous Lua filters transform manuscript
content during rendering.

It is the source-of-truth guide for Div class contracts and two-column table
policy behavior.

## Active Filters

Panpreposterous runs these filters in order:

1. [filters/mermaid.lua](../filters/mermaid.lua)
2. [filters/backmatter.lua](../filters/backmatter.lua)
3. [filters/supplementary.lua](../filters/supplementary.lua)

## Mermaid Filter Contracts

The Mermaid filter converts fenced Mermaid code blocks to vector diagram assets
before LaTeX rendering. It calls Mermaid CLI to produce SVG, converts SVG to
PDF with `rsvg-convert`, and emits LaTeX figure floats.

Supported author controls include captions, labels, LaTeX width/max-height,
float placement, render height, background color, theme, node fill/text/border
colors, and line color. The default `base` theme is tuned for manuscript PDFs:
flowchart nodes are white, labels are dark SVG text, and borders/arrows use a
neutral gray so SVG-to-PDF conversion preserves readability.

In two-column manuscripts, `.fullwidth`, `.wide`, `.widetable`, and `.starred`
Mermaid blocks render as `figure*` floats.

### Float placement semantics

The following defaults are implemented by filters and apply unless overridden by
author attributes.

| Construct | Placement attribute | Default | Emitted LaTeX float |
| --- | --- | --- | --- |
| Mermaid block | `placement` | `!htbp` | `figure` |
| Mermaid block with `.fullwidth` / `.wide` / `.widetable` / `.starred` | `placement` | `!t` | `figure*` |
| Markdown table wrapper with `.fullwidth` / `.widetable` / `.starred` | `placement` | `t` | `table*` |

Practical guidance:

- Use `!htbp` when a diagram should stay close to its first mention.
- Use `t` or `!t` to bias placement to the top of a page in two-column output.
- Use `tb` or `!tbp` for wide tables when top-only placement is too strict.

## Backmatter Filter Contracts

The backmatter filter controls layout wrappers, TeX includes, and markdown table
handling in two-column mode.

### Contract: backmatter

Use `backmatter` for acknowledgements, contributions, and related end sections.

Before:

````markdown
::: backmatter
## Acknowledgements {-}
We thank collaborators.
:::
````

After (conceptual):

- content is wrapped in the LaTeX `backmatter` environment
- if `.onecol` is also present, content switches to one column for that block
  and returns to two columns afterward

### Contract: wide

Use `wide` to force a full-width island via the template `wideblock`
environment.

Before:

````markdown
::: wide
Wide content goes here.
:::
````

After (conceptual):

- content is emitted between `\begin{wideblock}` and `\end{wideblock}`

### Contract: onecol

Use `onecol` to temporarily switch to one-column layout anywhere in the body.

Before:

````markdown
::: onecol
This section should render in one column.
:::
````

After (conceptual):

- emits `\onecolumn` before the block
- emits `\twocolumn` after the block

### Contract: texinclude

Use `texinclude` to include an external TeX file directly.

Before:

````markdown
::: {.texinclude src="tables/table1.tex"}
:::
````

After (conceptual):

- emits `\input{tables/table1.tex}`

Notes:

- `src` is preferred; `file` is also accepted as a fallback attribute key
- the referenced file must be present in the mounted manuscript workspace

## Markdown Table Policy in Two-Column Mode

When `twocolumn: true`, markdown tables are suppressed by default unless
explicitly allowed.

### Default behavior

Before:

````markdown
| Group | n | Mean |
| --- | ---: | ---: |
| Control | 12 | 1.03 |
````

After (conceptual):

- the table is suppressed
- a visible warning box is inserted in the PDF
- a stderr warning is emitted during render

### Override: allow inline markdown table

Add `.allowmd` to render the markdown table inline in two-column mode.

Before:

````markdown
::: {.allowmd}
| Group | n | Mean |
| --- | ---: | ---: |
| Control | 12 | 1.03 |
:::
````

After (conceptual):

- table is rendered normally in-place

### Override: force one-column table island

Add `.onecol` to force one-column rendering for markdown tables.

Before:

````markdown
::: {.onecol}
| Group | n | Mean |
| --- | ---: | ---: |
| Control | 12 | 1.03 |
:::
````

After (conceptual):

- emits `\onecolumn`
- renders the table
- emits `\twocolumn`

### Override: full-width floating markdown table

Add `.fullwidth` to render a markdown table as a two-column `table*` float.
The aliases `.widetable` and `.starred` are also accepted. Use the optional
`placement` attribute to choose the LaTeX float placement; it defaults to `t`.

Before:

````markdown
::: {#tbl:wide-example .fullwidth placement="tb"}
| Design choice | Markdown-first path | Raw-LaTeX fallback |
| --- | --- | --- |
| Wide prose table | Floats across both columns | Author-maintained `table*` block |
| Cell wrapping | Ragged-right fixed-width columns | Manual column specification |

Table: **Wide table example.** A full-width Markdown table.
:::
````

After (conceptual):

- emits `\begin{table*}[tb]`
- preserves the table caption and wrapper id as the LaTeX caption and label
- renders fixed-width `p{}` columns as ragged-right columns using
  `>{\raggedright\arraybackslash}p{...}`
- emits `\end{table*}`

### YAML override key

You can override strict suppression with YAML metadata:

````yaml
forbid_markdown_tables: false
````

When set to `false`, markdown tables are not globally suppressed in two-column
mode.

## Supplementary Filter Contracts

The supplementary filter defers supplementary content to document end and
builds summary lists when figures/tables are present.

### Contract: supplementary

Before:

````markdown
::: supplementary
Supplementary text.

![Supplementary figure](figs/s1.png){#fig:s1}
:::
````

After (conceptual):

- supplementary Div is removed from its original location
- supplementary content is emitted at end of document inside
  `\begin{supplementary} ... \end{supplementary}`
- if a leading header such as "Supplementary Materials" exists inside the Div,
  it is removed to avoid duplicate titles

### List generation behavior

When supplementary content includes figures or tables (markdown, Pandoc AST, or
LaTeX float blocks):

- a "List of Supplementary Figures" subsection is generated when figures exist
- a "List of Supplementary Tables" subsection is generated when tables exist
- labels are included as `\ref{...}` when available

### Pagination behavior

- inserts `\clearpage` after bibliography Div (`#refs`) when present
- applies `\clearpage` before each supplementary float so items are separated
  cleanly
- appends the supplementary material via `\AtEndDocument{...}`

## Authoring Recommendations

- In two-column manuscripts, prefer `.fullwidth` for wide markdown tables that
  should float across both columns.
- Prefer TeX include tables for complex custom layouts.
- Use `.onecol` for tables that must remain markdown but need readability.
- Use `.allowmd` sparingly, only when inline two-column rendering is acceptable.
- Keep supplementary figures and tables inside a single `supplementary` block.

## Related Documents

- Usage guide: [README.md](../README.md)
- Metadata contract: [docs/inputs.md](inputs.md)
- Architecture contracts: [docs/architecture.md](architecture.md)
- Workspace status anchor:
  [docs/anchor/workspace-architecture-anchor.md](anchor/workspace-architecture-anchor.md)
