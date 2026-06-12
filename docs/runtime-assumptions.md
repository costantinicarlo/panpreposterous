# Runtime Assumptions and Environment Constraints

## Purpose

This document captures environment-dependent assumptions that affect
Panpreposterous rendering outcomes and troubleshooting.

It defines what is supported, what can vary across hosts, and what is out of
scope for strict determinism.

## Supported Runtime Model

Panpreposterous is designed for container-first execution:

- render commands run inside the Panpreposterous Docker image
- manuscript workspace is mounted into the container at `/work`
- wrapper assets are expected at fixed in-container paths under
  `/opt/panpreposterous`

Direct host execution outside the container is not the primary support model.

## Filesystem and Path Assumptions

- the current working directory passed with `-v "$PWD":/work` is readable by
  Docker
- the output path passed with `-o` is writable within the mounted workspace
- referenced manuscript assets (figures, tables, TeX include files) resolve from
  the mounted directory tree
- wrapper-required files must remain readable in image layout:
  - `/opt/panpreposterous/template/preprint_template_xe_citeproc.tex`
  - `/opt/panpreposterous/filters/backmatter.lua`
  - `/opt/panpreposterous/filters/supplementary.lua`

Path contract ownership:

- `Dockerfile` is the source-of-truth for runtime path environment variables:
  - `PANPREPOSTEROUS_ROOT`
  - `PANPREPOSTEROUS_TEMPLATE_DIR`
  - `PANPREPOSTEROUS_FILTERS_DIR`
  - `PANPREPOSTEROUS_TEMPLATE_PATH`
  - `PANPREPOSTEROUS_BACKMATTER_FILTER_PATH`
  - `PANPREPOSTEROUS_SUPPLEMENTARY_FILTER_PATH`
- `bin/panpreposterous` consumes these variables and falls back to stable
  defaults when unset.
- CI validates readability of all required runtime assets inside the built
  image before publish.

Failure signals for path drift:

- wrapper preflight emits one of:
  - `required template not found or not readable`
  - `required Lua filter not found or not readable`
- CI fails in verify-build path validation if any required asset is unreadable.

## Shell Behavior Assumptions

- Wrapper help output is emitted through a `printf`-based function, not a
  heredoc block.
- CI validates that help output retains core structural sections (`Usage`,
  `Defaults`, `Example`).

Failure signals for shell/help regressions:

- CI `Verify help sections` step fails if any required section heading is
  missing.
- unexpected or truncated help output in local wrapper preflight.

## Font and TeX Toolchain Assumptions

- PDF rendering depends on the container-bundled TinyTeX distribution and TeX
  package set
- default template behavior expects XeLaTeX execution with bundled defaults
- host-installed fonts and TeX packages are not part of the supported
  compatibility contract

If custom metadata selects non-default fonts, those fonts must be available in
container runtime.

## Cross-Platform Variability

The following outputs may vary across host environments or build moments even
when visual rendering is acceptable:

- PDF byte content and checksum
- PDF file size
- embedded metadata fields (timestamps, producer details, object ordering)

Panpreposterous release gating is intentionally structural and does not require
strict byte-for-byte PDF identity.

For multi-architecture container releases (`linux/amd64` and `linux/arm64`),
byte-level PDF identity is not expected across architectures. Structural smoke
tests in CI are the authoritative release gate.

## Determinism Non-Goals

Out of scope for strict guarantees:

- identical PDF hashes across all hosts and execution moments
- identical byte size across all platforms
- host-level TeX/font parity outside container runtime

In scope for validation:

- successful render exit path
- non-empty PDF artifact
- expected structural sections and filter transformations

## Host and Docker Prerequisites

- Docker daemon is running and can mount local paths
- user has permission to access and write in the manuscript workspace
- available disk space is sufficient for image layers and render artifacts

## Troubleshooting Linkage

Use this assumptions reference together with:

- [docs/troubleshooting.md](troubleshooting.md)
- README quick checks in [README.md](../README.md)

## Related Documents

- Architecture contracts: [docs/architecture.md](architecture.md)
- Metadata contract: [docs/inputs.md](inputs.md)
- Filter behavior contract: [docs/filters.md](filters.md)
- Workspace status anchor:
  [docs/anchor/workspace-architecture-anchor.md](anchor/workspace-architecture-anchor.md)
