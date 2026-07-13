#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly IMAGE="panpreposterous:mermaid"

if ! command -v docker >/dev/null 2>&1; then
  printf 'docker is required for citation-input checks\n' >&2
  exit 1
fi

if ! docker image inspect "${IMAGE}" >/dev/null 2>&1; then
  printf 'Missing image %s. Build it with: docker build -t %s .\n' "${IMAGE}" "${IMAGE}" >&2
  exit 1
fi

tmp_root="$(mktemp -d)"
trap 'rm -rf "${tmp_root}"' EXIT

cp "${REPO_ROOT}/tests/metadata-citation-inputs.md" "${tmp_root}/manuscript.md"
cp "${REPO_ROOT}/examples/references.bib" "${tmp_root}/references.bib"
cp "${REPO_ROOT}/examples/journal.csl" "${tmp_root}/journal.csl"

# 1) Metadata-only bibliography/CSL should work without CLI flags.
docker run --rm -v "${tmp_root}:/work" -w /work "${IMAGE}" \
  /usr/local/bin/panpreposterous manuscript.md -o metadata-only.pdf

if [[ ! -s "${tmp_root}/metadata-only.pdf" ]]; then
  printf 'Metadata-only fixture failed: expected metadata-only.pdf\n' >&2
  exit 1
fi

if [[ ! -s "${tmp_root}/metadata-only.tex" ]]; then
  printf 'Metadata-only fixture failed: expected metadata-only.tex\n' >&2
  exit 1
fi

if grep -Fq '[@Smith2024]' "${tmp_root}/metadata-only.tex"; then
  printf 'Metadata-only fixture failed: citation key was not resolved\n' >&2
  exit 1
fi

# 2) Explicit CLI flags should still work with the same manuscript.
rm -f "${tmp_root}/manuscript.tex"
docker run --rm -v "${tmp_root}:/work" -w /work "${IMAGE}" \
  /usr/local/bin/panpreposterous manuscript.md --bibliography references.bib --csl journal.csl -o with-flags.pdf

if [[ ! -s "${tmp_root}/with-flags.pdf" ]]; then
  printf 'Flag-based fixture failed: expected with-flags.pdf\n' >&2
  exit 1
fi

if [[ ! -s "${tmp_root}/with-flags.tex" ]]; then
  printf 'Flag-based fixture failed: expected with-flags.tex\n' >&2
  exit 1
fi

if grep -Fq '[@Smith2024]' "${tmp_root}/with-flags.tex"; then
  printf 'Flag-based fixture failed: citation key was not resolved\n' >&2
  exit 1
fi

printf 'Citation input mode checks passed.\n'
