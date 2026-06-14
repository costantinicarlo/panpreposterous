---
twocolumn: true
---

Text before the wide table.

::: {#tbl:fullwidth-regression .fullwidth placement="tb"}
| Stage | Markdown contract | Expected LaTeX |
| --- | --- | --- |
| Float | `.fullwidth` wrapper | `table*` environment |
| Placement | `placement="tb"` | `[tb]` option |
| Caption | Pandoc table caption | LaTeX `\caption{...}` |

Table: **Full-width table regression.** This caption should be preserved.
:::

Text after the wide table.
