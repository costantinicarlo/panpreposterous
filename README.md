# Panpreposterous (pandoc-only)

A minimal, reproducible container that turns Markdown + YAML + CSL + BibTeX
into **preprint/postprint PDFs** using the XeLaTeX template and Lua filters.

## Build

```bash
docker build -t panpreposterous -f Dockerfile .
```

## Use

From your manuscript folder (so refs, csl, images are visible):

```bash
docker run --rm -v "$PWD":/work panpreposterous \
  panpreposterous manuscript.md --bibliography references.bib --csl journal.csl -o manuscript.pdf
```

### Template/YAML knobs (partial)

- `twocolumn: true`
- `running_title: "Short title"`
- `doc_version: "Preprint"`
- `correspondence: ["alice@uni.edu (A. Smith)"]`
- `csl_entry_spacing_extra: 0.25`
- Side DOIs (optional): `preprint_doi`, `preprint_doi_label`, `published_doi`, `published_doi_label`, plus `side_doi_color`, `side_doi_opacity`, `side_doi_shift`, `side_doi_rotation`.

### Supplementary Materials

Wrap supplementary content in a fenced Div:

````markdown
::: supplementary
(Some optional text.)

![S1 figure](figs/s1.pdf){#fig:s1}

Table: S1 caption {#tab:s1}
:::
````

The filter will:

- Balance references on the last two-column page
- Clear page after refs
- Generate lists of Figures/Tables
- Force one item per page in the supplement
- Number S1, S2, …

## License and Attribution

This repository is licensed under Creative Commons Attribution 4.0
International (CC BY 4.0). See the LICENSE file for details.

This project is adapted from:

- https://github.com/brenhinkeller/preprint-template.tex

The upstream source notes that it was forked and modified from:

- https://github.com/kourgeorge/arxiv-style

Further attribution and provenance notes are in the NOTICE file.
