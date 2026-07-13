#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly IMAGE="panpreposterous:mermaid"

if ! command -v docker >/dev/null 2>&1; then
  printf 'docker is required for references-heading checks\n' >&2
  exit 1
fi

if ! docker image inspect "${IMAGE}" >/dev/null 2>&1; then
  printf 'Missing image %s. Build it with: docker build -t %s .\n' "${IMAGE}" "${IMAGE}" >&2
  exit 1
fi

tmp_root="$(mktemp -d)"
trap 'rm -rf "${tmp_root}"' EXIT

cp "${REPO_ROOT}/examples/references.bib" "${tmp_root}/references.bib"
cp "${REPO_ROOT}/examples/journal.csl" "${tmp_root}/journal.csl"
cp "${REPO_ROOT}/tests/references-metadata-only.md" "${tmp_root}/references-metadata-only.md"
cp "${REPO_ROOT}/tests/references-manual-only.md" "${tmp_root}/references-manual-only.md"
cp "${REPO_ROOT}/tests/references-manual-plus-metadata.md" "${tmp_root}/references-manual-plus-metadata.md"

render_fixture() {
  local input_file="$1"
  local output_pdf="$2"

  docker run --rm -v "${tmp_root}:/work" -w /work "${IMAGE}" \
    /usr/local/bin/panpreposterous "${input_file}" -o "${output_pdf}"

  if [[ ! -s "${tmp_root}/${output_pdf}" ]]; then
    printf 'Reference fixture failed: expected %s\n' "${output_pdf}" >&2
    exit 1
  fi
}

render_fixture references-metadata-only.md references-metadata-only.pdf
render_fixture references-manual-only.md references-manual-only.pdf
render_fixture references-manual-plus-metadata.md references-manual-plus-metadata.pdf

if [[ ! -s "${tmp_root}/references-metadata-only.tex" ]]; then
  printf 'Reference fixture failed: expected references-metadata-only.tex\n' >&2
  exit 1
fi

if [[ ! -s "${tmp_root}/references-manual-only.tex" ]]; then
  printf 'Reference fixture failed: expected references-manual-only.tex\n' >&2
  exit 1
fi

if [[ ! -s "${tmp_root}/references-manual-plus-metadata.tex" ]]; then
  printf 'Reference fixture failed: expected references-manual-plus-metadata.tex\n' >&2
  exit 1
fi

if ! grep -Fq '\hypertarget{refs}' "${tmp_root}/references-metadata-only.tex"; then
  printf 'Metadata-only fixture failed: expected refs anchor insertion point\n' >&2
  exit 1
fi

if grep -Fq '\subsection*{Cited Works Contract}' "${tmp_root}/references-metadata-only.tex"; then
  printf 'Metadata-only fixture failed: unexpected auto-inserted references heading\n' >&2
  exit 1
fi

if ! grep -Fq '\subsection*{References}' "${tmp_root}/references-manual-only.tex"; then
  printf 'Manual fixture failed: expected manual references heading in TeX output\n' >&2
  exit 1
fi

guard_count="$(grep -F -c '\subsection*{Cited Works Contract}' "${tmp_root}/references-manual-plus-metadata.tex" || true)"
if [[ "${guard_count}" -ne 1 ]]; then
  printf 'Duplicate-heading guard failed: expected exactly one heading occurrence, found %s\n' "${guard_count}" >&2
  exit 1
fi

if grep -Fq '[@Smith2024]' "${tmp_root}/references-manual-plus-metadata.tex"; then
  printf 'Reference fixture failed: citation key was not resolved\n' >&2
  exit 1
fi

printf 'References heading contract checks passed.\n'
