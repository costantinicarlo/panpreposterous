#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly IMAGE="${IMAGE:-panpreposterous:mermaid}"

if ! command -v docker >/dev/null 2>&1; then
  printf 'docker is required for two-column plain verbatim checks\n' >&2
  exit 1
fi

if ! docker image inspect "${IMAGE}" >/dev/null 2>&1; then
  printf 'Missing image %s. Build it with: docker build -t %s .\n' "${IMAGE}" "${IMAGE}" >&2
  exit 1
fi

tmp_root="$(mktemp -d)"
trap 'rm -rf "${tmp_root}"' EXIT

cp "${REPO_ROOT}/tests/verbatim-twocolumn-plain.md" "${tmp_root}/verbatim-twocolumn-plain.md"

render_log="${tmp_root}/render.log"
docker run --rm -v "${tmp_root}:/work" -w /work "${IMAGE}" \
  /usr/local/bin/panpreposterous verbatim-twocolumn-plain.md -o verbatim-twocolumn-plain.pdf >"${render_log}" 2>&1

if [[ ! -s "${tmp_root}/verbatim-twocolumn-plain.pdf" ]]; then
  printf 'Two-column plain verbatim fixture failed: expected verbatim-twocolumn-plain.pdf\n' >&2
  cat "${render_log}" >&2
  exit 1
fi

if [[ ! -s "${tmp_root}/verbatim-twocolumn-plain.tex" ]]; then
  printf 'Two-column plain verbatim fixture failed: expected verbatim-twocolumn-plain.tex\n' >&2
  cat "${render_log}" >&2
  exit 1
fi

grep -Fq '\\RecustomVerbatimEnvironment{verbatim}{Verbatim}{%' "${tmp_root}/verbatim-twocolumn-plain.tex"
grep -Fq '\\begin{verbatim}' "${tmp_root}/verbatim-twocolumn-plain.tex"

if grep -Fq 'Overfull \\hbox' "${render_log}"; then
  printf 'Two-column plain verbatim fixture failed: detected overfull hbox from plain fence rendering\n' >&2
  cat "${render_log}" >&2
  exit 1
fi

printf 'Two-column plain verbatim checks passed.\n'
