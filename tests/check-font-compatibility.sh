#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly IMAGE="panpreposterous:mermaid"

if ! command -v docker >/dev/null 2>&1; then
  printf 'docker is required for font compatibility checks\n' >&2
  exit 1
fi

if ! docker image inspect "${IMAGE}" >/dev/null 2>&1; then
  printf 'Missing image %s. Build it with: docker build -t %s .\n' "${IMAGE}" "${IMAGE}" >&2
  exit 1
fi

tmp_root="$(mktemp -d)"
trap 'rm -rf "${tmp_root}"' EXIT

cp "${REPO_ROOT}/tests/font-unicode-default.md" "${tmp_root}/default.md"
cp "${REPO_ROOT}/tests/font-unicode-custom.md" "${tmp_root}/custom.md"
cp "${REPO_ROOT}/tests/font-unicode-missingfont.md" "${tmp_root}/missing.md"

# 1) Default fonts + Unicode symbols should render.
docker run --rm -v "${tmp_root}:/work" -w /work "${IMAGE}" \
  /usr/local/bin/panpreposterous default.md -o default.pdf

if [[ ! -s "${tmp_root}/default.pdf" ]]; then
  printf 'Default unicode fixture failed: expected default.pdf\n' >&2
  exit 1
fi

# 2) Explicit supported custom fonts should render.
docker run --rm -v "${tmp_root}:/work" -w /work "${IMAGE}" \
  /usr/local/bin/panpreposterous custom.md -o custom.pdf

if [[ ! -s "${tmp_root}/custom.pdf" ]]; then
  printf 'Custom font fixture failed: expected custom.pdf\n' >&2
  exit 1
fi

# 3) Missing font names should gracefully fallback and still render.
missing_log="${tmp_root}/missing.log"
docker run --rm -v "${tmp_root}:/work" -w /work "${IMAGE}" \
  /usr/local/bin/panpreposterous missing.md -o missing.pdf >"${missing_log}" 2>&1

if [[ ! -s "${tmp_root}/missing.pdf" ]]; then
  printf 'Missing-font fixture failed: expected missing.pdf\n' >&2
  cat "${missing_log}" >&2
  exit 1
fi

if [[ ! -s "${tmp_root}/missing.tex" ]]; then
  printf 'Missing-font fixture failed: expected missing.tex\n' >&2
  cat "${missing_log}" >&2
  exit 1
fi

grep -Fq '\PanMainFontName' "${tmp_root}/missing.tex"
grep -Fq 'Imaginary Serif Font' "${tmp_root}/missing.tex"
grep -Fq '\IfFontExistsTF' "${tmp_root}/missing.tex"
grep -Fq '\begin{document}' "${tmp_root}/missing.tex"

printf 'Font compatibility checks passed.\n'
