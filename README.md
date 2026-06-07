# Panpreposterous

Panpreposterous is a containerized command-line application for turning Markdown manuscripts into reproducible preprint and postprint PDFs.

It is designed for researchers who want a plain-text manuscript workflow: write the article in Markdown, keep references in BibTeX, choose a CSL citation style, and run one Docker command to produce a formatted PDF with Pandoc, XeLaTeX, a bundled article template, and Lua filters.

## What It Does

Panpreposterous takes an article folder like this:

```text
article/
  manuscript.md
  references.bib
  journal.csl
  figs/
    fig1.svg
  tables/
    table1.tex
```

and produces a PDF such as:

```text
article/
  manuscript-preprint.pdf
```

The build runs inside a Docker container so the Pandoc, XeLaTeX, template, Lua filters, and TeX packages are kept together in one reproducible environment.

## Who It Is For

Use Panpreposterous if you want to:

- Build a preprint or postprint PDF from Markdown.
- Keep manuscript text, references, figures, and tables in one folder.
- Use CSL files for journal-like citation formatting.
- Rebuild the same manuscript repeatedly as files change.
- Share a reproducible build command with collaborators.

Panpreposterous is not a word processor, bibliography manager, journal
submission portal, or manuscript tracking system. It expects organized input files and produces a PDF from them.

## What You Need

Before you start, you need:

- Docker Desktop installed and running.
- This repository cloned or downloaded.
- One manuscript folder containing at least:
  - `manuscript.md`
  - `references.bib`
  - `journal.csl`
  - any figures, tables, or supplementary files referenced by the manuscript

## Build the Container Image

From the Panpreposterous repository root, build the image once:

```bash
docker build -t panpreposterous -f Dockerfile .
```

After that, you can use the same local image to build any manuscript folder.

## Try the Bundled Example

The fastest way to see the application work is to render the included example.

If you have not built the image yet, build it from the repository root:

```bash
docker build -t panpreposterous -f Dockerfile .
```

Then run the example from the `examples/` folder:

```bash
cd examples
docker run --rm -v "$PWD":/work panpreposterous \
  panpreposterous manuscript.md --bibliography references.bib --csl journal.csl -o manuscript-preprint.pdf
```

The output should appear as:

```text
examples/manuscript-preprint.pdf
```

To render a postprint, change `doc_version: "Preprint"` to
`doc_version: "Postprint"` in `examples/manuscript.md`, then run the same command with a different output name:

```bash
docker run --rm -v "$PWD":/work panpreposterous \
  panpreposterous manuscript.md --bibliography references.bib --csl journal.csl -o manuscript-postprint.pdf
```

## Use It on Your Own Manuscript

Open a terminal in the folder that contains your manuscript inputs.

```bash
docker run --rm -v "$PWD":/work panpreposterous \
  panpreposterous manuscript.md --bibliography references.bib --csl journal.csl -o manuscript.pdf
```

What this command does:

- Mounts your current folder into the container as `/work`.
- Reads `manuscript.md`, `references.bib`, `journal.csl`, and referenced files.
- Uses the bundled template and Lua filters.
- Runs Pandoc with XeLaTeX and citeproc.
- Writes the PDF to `manuscript.pdf`.

You can pass extra Pandoc arguments after the manuscript file. The wrapper keeps these defaults:

- Template:
  `/opt/panpreposterous/template/preprint_template_xe_citeproc.tex`
- Lua filters:
  `/opt/panpreposterous/filters/backmatter.lua`
  and `/opt/panpreposterous/filters/supplementary.lua`
- PDF engine: `xelatex`
- Citation processing: enabled with `--citeproc`

## Recommended Article Folder Layout

Keep all manuscript inputs in one folder tree:

```text
article/
  manuscript.md
  references.bib
  journal.csl
  figs/
    fig1.svg
    s1.png
  tables/
    table1.tex
  output/
```

Then build from inside `article/`:

```bash
docker run --rm -v "$PWD":/work panpreposterous \
  panpreposterous manuscript.md --bibliography references.bib --csl journal.csl -o output/manuscript-preprint.pdf
```

Use short, stable file names and keep figure/table paths relative to the
manuscript folder.

## Minimal Manuscript Skeleton

The manuscript begins with YAML metadata, followed by Markdown content:

````markdown
---
title: "Example Manuscript"
author:
  - name: "First Author"
    affiliation: [1]
    corresponding: true
affiliations:
  - id: 1
    name: "Department of Biology"
running_title: "Example"
doc_version: "Preprint"
twocolumn: true
correspondence:
  - first.author@institute.edu (F. Author)
---

# Introduction

This is a citation [@Smith2024].

![Main figure](figs/fig1.svg){#fig:main width=0.9\\columnwidth}

# References {-}
::: {#refs}
:::
````

Common YAML fields include:

- `twocolumn: true`
- `running_title: "Short title"`
- `doc_version: "Preprint"` or `doc_version: "Postprint"`
- `correspondence: ["alice@uni.edu (A. Smith)"]`
- `csl_entry_spacing_extra: 0.25`
- `preprint_doi`, `preprint_doi_label`
- `published_doi`, `published_doi_label`
- `side_doi_color`, `side_doi_opacity`, `side_doi_shift`,
  `side_doi_rotation`

## Backmatter

Put acknowledgements, author contributions, competing interests, or similar sections in a `backmatter` block:

````markdown
::: backmatter
## Acknowledgements {-}
We thank collaborators.

## Author contributions {-}
FA designed and wrote the study.
:::
````

## Supplementary Materials

Wrap supplementary content in a fenced Div:

````markdown
::: supplementary
**Supplementary note text.**

![Supplementary figure legend.](figs/s1.png){#fig:s1 width=0.9\\columnwidth}

| Group | n | Mean | SD |
|---|---:|---:|---:|
| Control | 12 | 1.03 | 0.11 |
| Treatment | 12 | 1.27 | 0.14 |

Table: **Supplementary table legend.**
:::
````

The supplementary filter:

- Moves supplementary content to the end of the PDF.
- Adds lists of supplementary figures and tables when applicable.
- Starts supplementary figures and tables on separate pages.
- Clears the page after references when a references block is present.

## Tables and Two-Column Layouts

In two-column mode, complex Markdown tables can be hard to control. The backmatter filter suppresses Markdown tables by default when `twocolumn: true` unless you explicitly allow them.

For complex tables, use a LaTeX table file and include it from Markdown:

````markdown
::: {.texinclude src="tables/table1.tex"}
:::
````

For a Markdown table that should appear as a one-column island, add the
`.onecol` class. For a Markdown table that should render inline despite two-column mode, add `.allowmd`.

## Troubleshooting Quick Checks

If Docker cannot find the image, build it first:

```bash
docker build -t panpreposterous -f Dockerfile .
```

If no PDF appears:

- Check that your terminal is in the manuscript folder.
- Check that `-o` points to a writable path.
- Create the output folder first if using a path such as `output/file.pdf`.

If citations appear as raw keys such as `[@Smith2024]`:

- Check that `--bibliography references.bib` points to the correct file.
- Check that citation keys in Markdown match entries in the `.bib` file.
- Check that the bibliography file is valid BibTeX.

If figures do not appear:

- Check that image paths are relative to the manuscript folder.
- Check that the files exist inside the folder mounted into Docker.
- Try a `.png` or `.pdf` fallback if an SVG renders unexpectedly.

## Further Guides

- New to the workflow:
  [Tutorial: Produce a Complete Preprint/Postprint PDF](docs/tutorial-produce-complete-preprint-postprint-pdf.md)
- Have your files ready:
  [How to Produce a Preprint/Postprint PDF](docs/how-to-produce-preprint-postprint-pdf.md)
- Want a complete starter:
  [Bundled Example Manuscript](examples/README.md)
- Maintaining releases:
  [Container Image Lineage](docs/release/container-image-lineage.md)

## Maintainer Notes

Container publishing is automated with GitHub Actions:

- Workflow: [.github/workflows/publish-image.yml](.github/workflows/publish-image.yml)
- Push a tag like `v1.1.0` to publish `1.1.0` and `latest`
- Or run workflow dispatch with `image_tag` and optional `push_latest`

Repository secrets required:

- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

## License and Attribution

This repository is licensed under Creative Commons Attribution 4.0
International (CC BY 4.0). See the [LICENSE](LICENSE) file for details.

This project is adapted from:

- <https://github.com/brenhinkeller/preprint-template.tex>

The upstream source notes that it was forked and modified from:

- <https://github.com/kourgeorge/arxiv-style>

Further attribution and provenance notes are in the [NOTICE](NOTICE) file.
