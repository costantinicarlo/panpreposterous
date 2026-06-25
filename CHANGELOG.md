# Changelog

All notable changes to Panpreposterous are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project aims to follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Container images are published to Docker Hub at
`docker.io/costantinicarlo/panpreposterous`, tagged with the exact semantic
version and, for tag-triggered releases, `latest` by the release pipeline.
Image provenance and the historical baseline are recorded in
[docs/release/container-image-lineage.md](docs/release/container-image-lineage.md).

This changelog begins tracking changes from the current development cycle;
earlier published image tags predate it and are covered by the lineage record.

## [Unreleased]

No entries yet.

## [1.4.1] - 2026-06-25

Patch release for the 1.4 Mermaid rendering line, prepared for Docker Hub as
`costantinicarlo/panpreposterous:1.4.1`.

### Fixed

- Mermaid flowchart labels now remain readable after SVG-to-PDF conversion by
  using a manuscript-safe default `base` theme, white node fills, dark node
  text, and neutral gray borders/arrows.
- Mermaid flowcharts now render labels as SVG text instead of Mermaid HTML
  labels, avoiding `foreignObject` output that can be lost during PDF
  conversion.

### Added

- Mermaid code block attributes for theme and default color overrides:
  `theme`, `primary-color`, `primary-text-color`, `primary-border-color`, and
  `line-color`.
- Regression checks asserting Mermaid default node fill, text color, SVG text
  labels, and absence of `foreignObject` labels.

### Documentation

- Mermaid authoring docs and the manuscript input contract now document the
  default diagram theme and color override attributes.
- Runtime, architecture, filter, and release-lineage documentation now include
  the Mermaid filter and Puppeteer config as part of the container runtime
  contract.

## [1.4.0] - 2026-06-23

Release focused on Mermaid diagram rendering, optional intermediate TeX sidecar
generation, and strengthened CI release gates.

### Added

- Mermaid diagram rendering support through the default Lua filter chain.
- Container runtime dependencies for Mermaid rendering (`mermaid-cli`, Chromium,
  Puppeteer config).
- Optional manuscript metadata key `keep_intermediate_tex: true` to emit a
  sidecar `.tex` file alongside the requested PDF output.
- Regression suite for Mermaid Phase 5 behaviour
  (`tests/check-mermaid-phase5.sh`) and related fixtures.
- Regression suite for intermediate TeX sidecar behaviour
  (`tests/check-intermediate-tex.sh`) and related fixtures.
- Diagram authoring guide in [docs/diagrams.md](docs/diagrams.md).
- Full-width floating Markdown tables: a table marked `.fullwidth` is emitted
  as a `table*` float spanning both columns, preserving caption and label,
  instead of being forced onto its own page as a one-column island.
- Regression test covering the full-width Markdown table contract.

### Changed

- CI workflow now includes a dedicated `verify-mermaid-phase5` job and gates
  publish on both `verify-mermaid-phase5` and `verify-build`.
- Runtime asset verification now explicitly checks Mermaid filter path
  availability.
- Documentation updated to describe Mermaid usage and intermediate TeX behaviour
  in [README.md](README.md), [docs/inputs.md](docs/inputs.md),
  [docs/filters.md](docs/filters.md), and examples.

### Planned

- Refactor the baseline image to build on official Pandoc container images.
- Add a Typst rendering backend alongside the existing XeLaTeX backend, with a
  backend-neutral metadata schema (targeted for a future major release).

## [1.3.0]

Current published image (`costantinicarlo/panpreposterous:latest`), built for `linux/amd64` and `linux/arm64`. Bundles Pandoc 2.17.1.1 with a TinyTeX-supplied TeX Live 2026 distribution and the XeLaTeX engine.

### Added

- Multi-architecture image builds (`linux/amd64`, `linux/arm64`).
- Release automation that publishes only after a `verify-build` job rebuilds the image, runs `panpreposterous --help`, and renders the bundled example end to end.
- Non-blocking lineage scaffold verification on pull requests to `main`.

## [1.0] - 2025-11-26

Initial public container image (`linux/amd64`).

### Added

- Containerised Pandoc + XeLaTeX pipeline producing two-column preprint and
  postprint PDFs from Markdown manuscripts.
- Adapted two-column LaTeX template and style.
- Backmatter and supplementary Lua filters, including the two-column Markdown table policy.
- Thin command-line wrapper with input and asset validation.
