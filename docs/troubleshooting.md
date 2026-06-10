# Troubleshooting Guide

## Purpose

This guide helps diagnose common Panpreposterous render failures and links to
environment assumptions that can cause host-specific behavior.

## Start Here

Before deeper debugging, run the quick checks in:

- [README.md](../README.md)

Then confirm environment constraints in:

- [docs/runtime-assumptions.md](runtime-assumptions.md)

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
