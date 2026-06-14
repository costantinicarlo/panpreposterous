---
title: "`Panpreposterous` Example Manuscript"
author:
  - name: "First Author"
    affiliation: [1]
    corresponding: true
affiliations:
  - id: 1
    name: "Department of Biology, Some University, Any Country"
running_title: "Example"
doc_version: "Preprint"
twocolumn: true
correspondence:
  - first.author@institute.edu (F. Author)
abstract: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
keywords: ["Open Science", "reproducibility", "`pandoc`", "preprint", "postprint", "academic article"]
preprint_doi_label: "ExarXiv preprint v.2 - DOI"
preprint_doi: "10.9999/exa.io/XYZ"
side_doi_shift: 0.8cm
---

# Introduction

This example includes one citation [@Smith2024].

And an equation:

$$
xi _{ij}(t)= {\frac {\alpha _{i}(t)a^{w_t}_{ij}\beta _{j}(t+1)b^{v_{t+1}}_{j}(y_{t+1})}{\sum _{i=1}^{N} \sum _{j=1}^{N} \alpha _{i}(t)a^{w_t}_{ij}\beta _{j}(t+1)b^{v_{t+1}}_{j}(y_{t+1})}} \tag{Eq. 1}
$$

# Methods

Methods text. This section also includes a \LaTeX table block.

::: {.texinclude src="tables/table1.tex"}
:::

# Results

Results text.

::: {#tbl:fullwidth-example .fullwidth placement="tb"}
| Analysis stage | Markdown-first workflow | Raw-LaTeX fallback |
| --- | --- | --- |
| Authoring | Keep wide prose tables in the manuscript source. | Maintain a separate `table*` environment by hand. |
| Layout | Float the table across both columns near its reference. | Tune placement in raw TeX for each manuscript. |
| Wrapped cells | Use ragged-right fixed-width columns when Pandoc supplies widths. | Add `>{\raggedright\arraybackslash}p{...}` manually. |

Table: **Full-width Markdown table example.** The `.fullwidth` contract renders this table as a two-column `table*` float.
:::

![Main figure](figs/fig1.svg){#fig:main width=0.9\\columnwidth}

# Discussion

Discussion text.

# References {-}

::: {#refs}
:::

::: backmatter

## Acknowledgements {-}

We thank collaborators.

## Author contributions {-}

FA designed and wrote the study.
:::

::: supplementary
**Supplementary note text.**

Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?

![Supplementary figure legend.](figs/s1.png){#fig:s1 width=0.9\\columnwidth}

| Group | n | Mean | SD |
| --- | ---: | ---: | ---: |
| Control | 12 | 1.03 | 0.11 |
| Treatment A | 12 | 1.27 | 0.14 |
| Treatment B | 12 | 1.41 | 0.18 |

Table: **Supplementary table legend.** Example summary statistics for supplementary analysis.
:::
