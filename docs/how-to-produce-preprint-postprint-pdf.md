## How to Produce a Preprint/Postprint PDF from an Article Folder

This guide is for scientists who want a reliable way to turn manuscript
materials into a publication-ready PDF.

By the end, you will be able to:

- Organize your article files in one folder.
- Choose key formatting options ahead of time.
- Build a preprint/postprint PDF in a repeatable way.
- Diagnose and fix common problems.

### Before You Start: Planning Checklist

Prepare one article folder containing all manuscript inputs.

Required:

- Main manuscript text in Markdown, for example `manuscript.md`.

Usually needed:

- Reference database, for example `references.bib`.
- Citation style file, for example `journal.csl`.
- Figures, for example `.png`, `.jpg`, `.svg`, or `.pdf` files.

Optional but common:

- LaTeX tables in `.tex` files.
- Supplementary items (figures/tables/text).
- Metadata in the YAML header (title, authors, correspondence, and so on).

Decide these points before building:

- Do you want a two-column layout (`twocolumn: true`)?
- Should the document be marked as preprint or postprint (`doc_version`)?
- Which citation style should be used (`--csl`)?
- Which output file name should be produced (`-o`)?

### Recommended Article Folder Layout

Use a simple structure so paths stay stable across revisions:

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

If you want a ready-to-run starter bundle, use [examples](../examples).

Practical naming tips:

- Use short, descriptive file names.
- Avoid duplicate names like `figure-final-final.png`.
- Keep all files for this article inside the same folder tree.

### Step-by-Step Build Workflow

#### 1. Open a terminal in your article folder

Your terminal location should be the folder that contains `manuscript.md`.

#### 2. Run the PDF build command

```bash
docker run --rm -v "$PWD":/work panpreposterous \
  panpreposterous manuscript.md --bibliography references.bib --csl journal.csl -o output/manuscript.pdf
```

What this does:

- Uses your current folder as the working data source.
- Reads manuscript text, references, and style.
- Produces the output PDF at `output/manuscript.pdf`.

#### 3. Check the result

- Confirm the PDF exists at your chosen output path.
- Open it and inspect title page, citations, figures, and references.

### Add Common Manuscript Elements

Add these in your manuscript YAML header when needed.

Common examples:

- `twocolumn: true`
- `running_title: "Short title"`
- `doc_version: "Preprint"`
- `correspondence: ["name@institute.edu (A. Author)"]`

Supplementary material block:

````markdown
::: supplementary
![Supplementary figure S1](figs/s1.png){#fig:s1}

Table: Supplementary table S1 {#tab:s1}
:::
````

Large or advanced tables in two-column documents:

- If needed, keep complex tables in separate `.tex` files.
- Include them using a `texinclude` block:

````markdown
::: {.texinclude src="tables/table1.tex"}
:::
````

### Quality Check Before Sharing

Before submission or distribution, verify:

- The title, author list, and affiliations are correct.
- In-text citations match the reference list.
- Figures are readable (labels, axes, legends, scale bars).
- Tables are complete and legible.
- Supplementary items are numbered correctly.
- The output version label matches your intention (preprint/postprint).

### Troubleshooting

#### Docker or command issues

Problem: Docker command is not available.

- Check that Docker Desktop is installed and running.
- Retry after Docker startup completes.

Problem: `panpreposterous` image not found.

- Build the image first:

```bash
docker build -t panpreposterous -f Dockerfile .
```

Problem: Command runs but no PDF appears.

- Confirm you are in the article folder.
- Confirm `-o` points to a valid writable path.
- Create target folders first (for example `output/`).

#### File and path issues

Problem: "file not found" for manuscript, bibliography, or CSL.

- Confirm file names match exactly (including extension).
- Confirm paths are relative to your article folder.
- Avoid moving assets after writing links in Markdown.

Problem: Paths with spaces behave unexpectedly.

- Keep article folder names simple when possible.
- If needed, quote paths carefully in your commands.

Problem: Permission denied when writing output.

- Write to a folder you own inside the mounted article directory.
- Avoid protected system folders.

#### Citations and references

Problem: Citations appear as raw keys (for example `[@Smith2023]`).

- Confirm `--bibliography` points to the correct `.bib` file.
- Confirm citation keys in text match keys in the `.bib` file.

Problem: Wrong citation style in output.

- Confirm `--csl` points to the intended style file.
- Rebuild after changing style.

Problem: Reference list is missing.

- Ensure a references section placeholder exists if your manuscript pattern uses one.
- Confirm bibliography file is non-empty and valid.

#### Figure and image issues

Problem: Figure does not appear.

- Confirm image path is correct.
- Confirm the file exists and is readable.
- Check that figure links in Markdown point to the right folder.

Problem: Figure quality is poor.

- Prefer higher-resolution source images.
- Use vector formats where practical for line drawings.

Problem: Figure spills into the next column in two-column layout.

- Use a column-based width for that figure, for example:
  `![Figure](figs/fig1.svg){#fig:main width=0.9\\columnwidth}`
- Avoid large percentage widths that can be interpreted against full text width.

Problem: SVG figure does not render as expected.

- Test with an alternative format (`.png` or `.pdf`) for that figure.
- Keep a fallback copy for critical figures.

Problem: JPEG photos look too compressed.

- Re-export from source with higher quality settings.
- Avoid repeated re-saving of JPEG files.

#### Table issues

Problem: Table formatting breaks in two-column mode.

- Move complex tables to `.tex` and include via `texinclude`.
- For Markdown tables in two-column manuscripts, consider one-column placement
  where needed.

Problem: Table disappears or is replaced by a warning in two-column output.

- This can happen when Markdown tables are restricted in two-column mode.
- Use one-column handling for that table or include a `.tex` table.

#### Metadata and layout issues

Problem: Running title or document version is not what you expect.

- Re-check YAML header keys and spelling.
- Rebuild after metadata edits.

Problem: Supplementary material is not formatted as expected.

- Ensure content is inside a `supplementary` block.
- Check figure/table labels for uniqueness.

Problem: Layout looks crowded.

- Shorten very long figure captions.
- Reduce oversized figures.
- Move very detailed tables to supplementary material.

#### Process and reproducibility issues

Problem: A collaborator cannot reproduce your output.

- Share the full article folder, not only the manuscript file.
- Include references, CSL, figures, and tables together.
- Share the exact command you used.

### Reproducible Routine for Revisions

For each manuscript revision:

1. Update manuscript and assets in the same article folder.
2. Re-run the same command pattern.
3. Save output with a clear version name.
4. Keep a short build log in your project notes.

### Quick Command Reference

Minimal command pattern:

```bash
docker run --rm -v "$PWD":/work panpreposterous \
  panpreposterous manuscript.md -o manuscript.pdf
```

Common full command pattern:

```bash
docker run --rm -v "$PWD":/work panpreposterous \
  panpreposterous manuscript.md --bibliography references.bib --csl journal.csl -o output/manuscript.pdf
```
