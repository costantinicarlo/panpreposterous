## Bundled Example Manuscript

This folder contains a complete, runnable example that matches the tutorial and
how-to workflow.

### Contents

- `manuscript.md`: main text with references, backmatter, and supplementary
  blocks
- `references.bib`: bibliography database used by citation keys in manuscript
- `journal.csl`: citation style file used in render commands
- `figs/`: figures (`fig1.svg` and `s1.png` for supplementary Figure S1)
- `tables/`: LaTeX table include (`table1.tex`)

Note: `manuscript.md` references `figs/s1.png` in the supplementary block.
Add that file before rendering if it is not present.

### Build from this folder

From repository root:

```bash
docker build -t panpreposterous -f Dockerfile .
```

Then from this `examples/` folder:

```bash
docker run --rm -v "$PWD":/work panpreposterous \
  panpreposterous manuscript.md --bibliography references.bib --csl journal.csl -o manuscript-preprint.pdf
```

To render postprint output, set `doc_version: "Postprint"` in `manuscript.md`
and run:

```bash
docker run --rm -v "$PWD":/work panpreposterous \
  panpreposterous manuscript.md --bibliography references.bib --csl journal.csl -o manuscript-postprint.pdf
```