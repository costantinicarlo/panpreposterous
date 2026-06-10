# Troubleshooting Guide

## Purpose

This guide helps diagnose common Panpreposterous render failures and links to
environment assumptions that can cause host-specific behavior.

## Start Here

Before deeper debugging, run the quick checks in:

- [README.md](../README.md)

Then confirm environment constraints in:

- [docs/runtime-assumptions.md](runtime-assumptions.md)

## Command-Level Validation Playbooks

Run these playbooks in order to narrow failures quickly.

### Playbook 1: Image Pull or Build

Command path A (published image):

```bash
docker pull costantinicarlo/panpreposterous:latest
```

Command path B (local build):

```bash
docker build -t panpreposterous -f Dockerfile .
```

Expected output signals:

- `docker pull` ends with a downloaded/existing image confirmation
- `docker build` ends with a successful image build message

Common failure signatures:

- `pull access denied`
- `manifest unknown`
- daemon connectivity errors
- build step failure inside Dockerfile

Assumptions linked:

- runtime model in [docs/runtime-assumptions.md](runtime-assumptions.md#supported-runtime-model)
- host prerequisites in [docs/runtime-assumptions.md](runtime-assumptions.md#host-and-docker-prerequisites)

### Playbook 2: Wrapper Preflight in Container

Command:

```bash
docker run --rm panpreposterous panpreposterous --help
```

Expected output signals:

- wrapper usage text is printed
- command exits successfully

Common failure signatures:

- container runtime launch errors
- wrapper startup errors about missing `/opt/panpreposterous/...` assets

Assumptions linked:

- fixed path assumptions in [docs/runtime-assumptions.md](runtime-assumptions.md#filesystem-and-path-assumptions)

### Playbook 3: Smoke Render Validation

Command:

```bash
smoke_dir="$(mktemp -d)" && \
cp examples/manuscript.md "$smoke_dir"/ && \
cp examples/references.bib "$smoke_dir"/ && \
cp examples/journal.csl "$smoke_dir"/ && \
cp -R examples/figs "$smoke_dir"/ && \
cp -R examples/tables "$smoke_dir"/ && \
docker run --rm -v "$smoke_dir":/work panpreposterous \
  panpreposterous manuscript.md --bibliography references.bib --csl journal.csl -o smoke-render.pdf && \
test -s "$smoke_dir/smoke-render.pdf"
```

Expected output signals:

- container render command exits successfully
- `smoke-render.pdf` exists and is non-empty

Common failure signatures:

- missing-file errors for bibliography/CSL/assets
- permission denied on mounted directory or output path
- LaTeX/Pandoc render failure with non-zero exit status

Assumptions linked:

- filesystem expectations in [docs/runtime-assumptions.md](runtime-assumptions.md#filesystem-and-path-assumptions)
- TeX/toolchain assumptions in [docs/runtime-assumptions.md](runtime-assumptions.md#font-and-tex-toolchain-assumptions)

### Playbook 4: Symptom Branching

Use this branch-and-bound sequence after Playbooks 1-3:

1. If pull/build fails: address daemon, tag, or registry/auth issues first.
2. If help fails: treat as runtime image or wrapper path integrity issue.
3. If help succeeds but smoke render fails: treat as manuscript input,
   permissions, or TeX/render issue.
4. If smoke render succeeds but output differs unexpectedly: check variability
   guidance in [docs/runtime-assumptions.md](runtime-assumptions.md#cross-platform-variability).

## Common Failure Classes

### Image Not Found

Symptoms:

- `docker run` reports image-not-found errors

Checks:

- pull the published image tag
- or build from local Dockerfile

### No Output PDF

Symptoms:

- command exits but expected output file is missing

Checks:

- confirm mounted workspace path is correct
- confirm output path is writable
- confirm output directory exists

### Citations Not Rendered

Symptoms:

- bibliography keys appear as raw `[@Key]` text

Checks:

- confirm `--bibliography` path is correct
- confirm `.bib` contains referenced keys
- confirm `--csl` path is correct

### Figures Missing

Symptoms:

- figures do not appear or appear unexpectedly

Checks:

- confirm asset paths are relative to manuscript root
- confirm files are included in mounted path tree
- test alternate formats for problematic SVG assets

### Wrapper Startup Path Errors

Symptoms:

- wrapper exits early with required template/filter path errors

Checks:

- confirm command runs inside container image
- confirm image layout includes `/opt/panpreposterous/template` and
  `/opt/panpreposterous/filters`

## Environment-Dependent Issues

When behavior differs across hosts or over time, consult:

- [docs/runtime-assumptions.md](runtime-assumptions.md)

This is especially relevant for PDF checksum and byte-size differences that are
not necessarily regressions.

## Related Documents

- Runtime assumptions: [docs/runtime-assumptions.md](runtime-assumptions.md)
- Usage and quickstart: [README.md](../README.md)
- Input contract: [docs/inputs.md](inputs.md)
- Filter behavior contract: [docs/filters.md](filters.md)
