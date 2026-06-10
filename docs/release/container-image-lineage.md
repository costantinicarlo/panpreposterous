# Container Image Lineage

This document records the known public container image lineage for
Panpreposterous.

## Legacy Docker Hub Baseline

The Docker Hub repository currently contains a published legacy image:

- Image: `docker.io/costantinicarlo/panpreposterous`
- Tag: `1.0`
- Digest:
  `sha256:437794f73a4a88162c0ae90cd8e48a0fcca5c11d41f045f6aa22b7236164b5be`
- Platform: `linux/amd64`
- Last pushed: `2025-11-26T14:40:50.471969105Z`

This image is treated as a frozen historical baseline.

## Phase 1 Policy

Until the legacy image is compared against the current tracked workspace:

- Do not republish tag `1.0`.
- Do not retag the legacy digest.
- Do not publish the current workspace image as `1.0`.
- Build the current workspace only as a local candidate image for comparison.

## Current Workspace Position

Architecture map source:

- [docs/architecture.md](../architecture.md)

The current workspace uses:

- [Dockerfile](../../Dockerfile)
- [bin/panpreposterous](../../bin/panpreposterous)
- [template/preprint_template_xe_citeproc.tex](../../template/preprint_template_xe_citeproc.tex)
- [template/panpreprint_1-0.sty](../../template/panpreprint_1-0.sty)
- [filters/backmatter.lua](../../filters/backmatter.lua)
- [filters/supplementary.lua](../../filters/supplementary.lua)

Because the legacy Docker Hub image may have been built from an untracked source state, it must be treated as a separate lineage until Phase 2 confirms whether the current workspace is compatible with it.

## Phase 2 Comparison Targets

Compare the legacy image and the current local candidate at two levels:

1. File-level comparison

- `/usr/local/bin/panpreposterous`
- `/opt/panpreposterous/template/*`
- `/opt/panpreposterous/filters/*`

1. Behavior-level comparison

- `panpreposterous --help`
- Sample manuscript render
- Bibliography output
- Supplementary output
- Backmatter output

## Phase 2 Outcome

Phase 2 comparison was completed successfully with the following result:

- extracted payloads: match
- CLI help output: match
- rendered PDF binaries: close visual match with expected metadata-level drift

The render hash and byte-size delta was accepted as non-blocking because PDF
binary output can vary across builds due to embedded metadata, while visual
output remained aligned.

## Phase 3 Automation

Publishing now moves through a GitHub Actions workflow:

- [Publish workflow](../../.github/workflows/publish-image.yml)

Build integrity is enforced before publish by the `verify-build` job, which:

- builds the container from the tracked [Dockerfile](../../Dockerfile)
- runs `panpreposterous --help` in the built image as a minimum runtime check
- renders the bundled example into a temporary workspace and verifies the PDF
  artifact is produced

The publish job runs only if `verify-build` succeeds.

## Non-Rigid Smoke-Test Policy

The smoke test is intentionally structural and evolution-friendly.

Release gate assertions:

- container build succeeds
- `panpreposterous --help` succeeds
- bundled example render succeeds
- output PDF exists and is non-empty

Allowed evolution model:

- template and filter changes may alter acceptable PDF content and layout
- CI does not enforce strict PDF hash matching
- CI does not enforce strict byte-size pinning

Optional future structural assertions may include:

- explicit renderer exit code checks (already enforced by `set -euo pipefail`)
- minimum page-count threshold checks when a stable cross-platform method is
  available

## Build Provenance Policy

TinyTeX is installed from a pinned release artifact and verified by SHA256
checksum during image build.

Current policy requirements:

- use a versioned non-prerelease asset from
  `rstudio/tinytex-releases`
- verify checksum before extraction
- fail build on checksum mismatch
- avoid pipe-to-shell installer execution

The pinned values are maintained in [Dockerfile](../../Dockerfile) via:

- `TINYTEX_RELEASE`
- `TINYTEX_ASSET`
- `TINYTEX_SHA256`

Rules:

- push a `v*` tag to publish `<version>` and `latest`
- run workflow dispatch to publish a specific `image_tag`
- optional `push_latest` toggle for manual dispatch
- never reuse `1.0`

## Release Implication

The next published image must use a new version tag after Phase 2, not `1.0`.

Phase-state source of truth:

- Machine-readable phase status is authoritative in
  [docs/release/legacy-image-baseline.json](legacy-image-baseline.json).
- This markdown file is the human-readable narrative and must stay aligned with
  that JSON state.

The machine-readable baseline for later automation is in
[docs/release/legacy-image-baseline.json](legacy-image-baseline.json).
