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

assert_tex_contains() {
  local pattern="$1"

  if ! grep -Fq "${pattern}" "${tmp_root}/hyperlink-colors.tex"; then
    printf 'Hyperlink fixture failed: expected TeX pattern %s\n' "${pattern}" >&2
    exit 1
  fi
}

assert_tex_contains '\hypersetup{'
assert_tex_contains 'colorlinks=true'
assert_tex_contains 'linkcolor=NavyBlue'
assert_tex_contains 'citecolor=NavyBlue'
assert_tex_contains 'urlcolor=NavyBlue'
assert_tex_contains 'filecolor=Red'
assert_tex_contains 'menucolor=Red'
assert_tex_contains 'runcolor=Red'
assert_tex_contains 'pdfborder={0 0 0}'

if grep -Fq '[@Smith2024]' "${tmp_root}/hyperlink-colors.tex"; then
  printf 'Hyperlink fixture failed: citation key was not resolved\n' >&2
  exit 1
fi

printf 'Hyperlink colour checks passed.\n'
