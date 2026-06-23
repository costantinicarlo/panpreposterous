# Changelog

All notable changes to Panpreposterous are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project aims to follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Container images are published to Docker Hub at
`docker.io/costantinicarlo/panpreposterous`, tagged `X.Y.Z`, `X.Y`, and `latest` by the release pipeline. Image provenance and the historical baseline are recorded in [docs/release/container-image-lineage.md](docs/release/container-image-lineage.md).

This changelog begins tracking changes from the current development cycle;
earlier published image tags predate it and are covered by the lineage record.

## [Unreleased]

### Added

- Full-width floating Markdown tables: a table marked `.fullwidth` is emitted as a `table*` float spanning both columns, preserving caption and label, instead of being forced onto its own page as a one-column island.
- Regression test covering the full-width Markdown table contract.
- Naming and typography policy document.
- Bundled-example documentation for the full-width Markdown table contract.

### Changed

- Documentation updated to describe the full-width table behaviour in
  [docs/filters.md](docs/filters.md), the README, and the examples.

### Planned

- Refactor the baseline image to build on official Pandoc container images.
- Add a Typst rendering backend alongside the existing XeLaTeX backend, with a backend-neutral metadata schema (targeted for a future major release).

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
