## Tutorial: Build a Complete Preprint and Postprint PDF

This tutorial is a guided lesson for scientists with little command-line
experience. You will follow one path from start to finish and produce two
outputs:

- A complete preprint PDF
- A complete postprint PDF

### Why this workflow exists

A manuscript usually combines many artifacts: main text, references, figures,
tables, supplementary material, and backmatter. Panpreposterous gives you one
repeatable way to assemble these into consistent publication-ready PDFs.

### What you will learn

You will learn how to:

1. Organize one article folder.
2. Create a minimal manuscript that includes references, backmatter, and
   supplementary material.
3. Build a preprint PDF.
4. Build a postprint PDF from the same source.

### Before you start

You need:

- Docker Desktop running.
- The Panpreposterous image built once from the repository root.

```bash
docker build -t panpreposterous -f Dockerfile .
```

### Step 1: Create your lesson folder

Create one folder called `article` with this structure:

```text
article/
  manuscript.md
  references.bib
  journal.csl
  figs/
    fig1.svg
  tables/
    table1.tex
  output/
```

Shortcut: you can copy the bundled starter from [examples](../examples) into
your own `article` folder and edit from there.

Checkpoint:

- You can see all files and folders above in one place.

### Step 2: Add a tiny bibliography file

Put this content in `references.bib`:

```bibtex
@article{Smith2024,
  author = {Smith, Jane and Doe, John},
  title = {An Example Study},
  journal = {Journal of Examples},
  year = {2024},
  volume = {1},
  number = {1},
  pages = {1--10}
}
```

Checkpoint:

- The file `references.bib` exists and contains the key `Smith2024`.

### Step 3: Prepare your manuscript file

Put this content in `manuscript.md`:

````markdown
---
title: "Tutorial Manuscript"
author:
  - name: "First Author"
    affiliation: [1]
    corresponding: true
affiliations:
  - id: 1
    name: "Department of Biology"
running_title: "Tutorial"
doc_version: "Preprint"
twocolumn: true
correspondence:
  - first.author@institute.edu (F. Author)
---

# Introduction

This is a tutorial manuscript with one citation [@Smith2024].

![Main figure](figs/fig1.svg){#fig:main width=0.9\\columnwidth}

# Methods

Methods text.

::: {.texinclude src="tables/table1.tex"}
:::

# Results

Results text.

# Discussion

Discussion text.

# References
::: {#refs}
:::

::: backmatter
## Acknowledgements
We thank collaborators.

## Author contributions
FA designed and wrote the study.
:::

::: supplementary
Table: Supplementary table S1 {#tab:s1}
:::
````

Checkpoint:

- Your manuscript includes all three structural pieces:
  - references placeholder
  - backmatter block
  - supplementary block

### Step 4: Build the preprint PDF

Open a terminal inside `article`, then run:

```bash
docker run --rm -v "$PWD":/work panpreposterous \
  panpreposterous manuscript.md --bibliography references.bib --csl journal.csl -o output/manuscript-preprint.pdf
```

Checkpoint:

- The file `output/manuscript-preprint.pdf` exists.
- The PDF shows citation formatting, references, backmatter, and supplementary
  content.

### Step 5: Build the postprint PDF from the same manuscript

Edit `manuscript.md` and change:

- `doc_version: "Preprint"` to `doc_version: "Postprint"`

Run:

```bash
docker run --rm -v "$PWD":/work panpreposterous \
  panpreposterous manuscript.md --bibliography references.bib --csl journal.csl -o output/manuscript-postprint.pdf
```

Checkpoint:

- The file `output/manuscript-postprint.pdf` exists.
- You now have both variants generated from one source file.

### What you accomplished

You completed a full, reproducible manuscript lesson:

1. Built one organized article folder.
2. Produced a complete preprint PDF.
3. Produced a complete postprint PDF.
4. Included references, backmatter, and supplementary material.

### Next step

For advanced options and full troubleshooting, continue with:

- [How to Produce a Preprint/Postprint PDF](docs/how-to-produce-preprint-postprint-pdf.md)