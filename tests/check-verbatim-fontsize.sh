#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly IMAGE="${IMAGE:-panpreposterous:mermaid}"

if ! command -v docker >/dev/null 2>&1; then
  printf 'docker is required for verbatim-fontsize checks\n' >&2
  exit 1
fi

if ! docker image inspect "${IMAGE}" >/dev/null 2>&1; then
  printf 'Missing image %s. Build it with: docker build -t %s .\n' "${IMAGE}" "${IMAGE}" >&2
  exit 1
fi

tmp_root="$(mktemp -d)"
trap 'rm -rf "${tmp_root}"' EXIT

cp "${REPO_ROOT}/tests/verbatim-fontsize.md" "${tmp_root}/verbatim-fontsize.md"

render_log="${tmp_root}/render.log"
docker run --rm -v "${tmp_root}:/work" -w /work "${IMAGE}" \
  /usr/local/bin/panpreposterous verbatim-fontsize.md -o verbatim-fontsize.pdf >"${render_log}" 2>&1

if [[ ! -s "${tmp_root}/verbatim-fontsize.pdf" ]]; then
  printf 'Verbatim fontsize fixture failed: expected verbatim-fontsize.pdf\n' >&2
  cat "${render_log}" >&2
  exit 1
fi

if [[ ! -s "${tmp_root}/verbatim-fontsize.tex" ]]; then
  printf 'Verbatim fontsize fixture failed: expected verbatim-fontsize.tex\n' >&2
  cat "${render_log}" >&2
  exit 1
fi

grep -Fq '\newcommand{\PanVerbatimOnePtSmaller}{%' "${tmp_root}/verbatim-fontsize.tex"
grep -Fq '\fontsize{\dimexpr\f@size pt-1pt\relax}{\dimexpr\baselineskip-1pt\relax}\selectfont' "${tmp_root}/verbatim-fontsize.tex"
grep -Fq 'formatcom=\PanVerbatimOnePtSmaller' "${tmp_root}/verbatim-fontsize.tex"
grep -Fq '\begin{Highlighting}[]' "${tmp_root}/verbatim-fontsize.tex"
grep -Fq '\begin{verbatim}' "${tmp_root}/verbatim-fontsize.tex"

if grep -Fq 'Environment Shaded undefined' "${render_log}"; then
  printf 'Verbatim fontsize fixture failed: Shaded environment undefined\n' >&2
  cat "${render_log}" >&2
  exit 1
fi

printf 'Verbatim fontsize checks passed.\n'
