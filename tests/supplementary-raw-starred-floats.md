---
twocolumn: true
---

# Supplementary Raw Starred Floats Fixture

Main text before supplementary content.

::: supplementary
Supplementary content containing raw LaTeX starred floats.

```{=latex}
\begin{figure*}[!t]
\centering
\rule{0.7\linewidth}{0.3\linewidth}
\caption{Raw LaTeX starred supplementary figure.}
\label{fig:s-raw-star}
\end{figure*}
```

```{=latex}
\begin{table*}[t]
\centering
\caption{Raw LaTeX starred supplementary table.}
\label{tbl:s-raw-star}
\begin{tabular}{ll}
\toprule
Item & Value \\
\midrule
Alpha & 1 \\
Beta & 2 \\
\bottomrule
\end{tabular}
\end{table*}
```
:::
