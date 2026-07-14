#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly IMAGE="${IMAGE:-panpreposterous:mermaid}"

if ! command -v docker >/dev/null 2>&1; then
  printf 'docker is required for hyperlink colour checks\n' >&2
  exit 1
fi

if ! docker image inspect "${IMAGE}" >/dev/null 2>&1; then
  printf 'Missing image %s. Build it with: docker build -t %s .\n' "${IMAGE}" "${IMAGE}" >&2
  exit 1
fi

tmp_root="$(mktemp -d)"
trap 'rm -rf "${tmp_root}"' EXIT

cp "${REPO_ROOT}/tests/hyperlink-colors.md" "${tmp_root}/hyperlink-colors.md"
cp "${REPO_ROOT}/examples/references.bib" "${tmp_root}/references.bib"
cp "${REPO_ROOT}/examples/journal.csl" "${tmp_root}/journal.csl"

render_log="${tmp_root}/render.log"
docker run --rm -v "${tmp_root}:/work" -w /work "${IMAGE}" \
  /usr/local/bin/panpreposterous hyperlink-colors.md --bibliography references.bib --csl journal.csl -o hyperlink-colors.pdf >"${render_log}" 2>&1

if [[ ! -s "${tmp_root}/hyperlink-colors.pdf" ]]; then
  printf 'Hyperlink fixture failed: expected hyperlink-colors.pdf\n' >&2
  cat "${render_log}" >&2
  exit 1
fi

if [[ ! -s "${tmp_root}/hyperlink-colors.tex" ]]; then
  printf 'Hyperlink fixture failed: expected hyperlink-colors.tex\n' >&2
  cat "${render_log}" >&2
  exit 1
fi

grep -Fq '\\hypersetup{' "${tmp_root}/hyperlink-colors.tex"
grep -Fq 'colorlinks=true' "${tmp_root}/hyperlink-colors.tex"
grep -Fq 'linkcolor=NavyBlue' "${tmp_root}/hyperlink-colors.tex"
grep -Fq 'citecolor=NavyBlue' "${tmp_root}/hyperlink-colors.tex"
grep -Fq 'urlcolor=NavyBlue' "${tmp_root}/hyperlink-colors.tex"
grep -Fq 'filecolor=Red' "${tmp_root}/hyperlink-colors.tex"
grep -Fq 'menucolor=Red' "${tmp_root}/hyperlink-colors.tex"
grep -Fq 'runcolor=Red' "${tmp_root}/hyperlink-colors.tex"
grep -Fq 'pdfborder={0 0 0}' "${tmp_root}/hyperlink-colors.tex"

if grep -Fq '[@Smith2024]' "${tmp_root}/hyperlink-colors.tex"; then
  printf 'Hyperlink fixture failed: citation key was not resolved\n' >&2
  exit 1
fi

printf 'Hyperlink colour checks passed.\n'
