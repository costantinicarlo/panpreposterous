#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly IMAGE="panpreposterous:mermaid"

if ! command -v docker >/dev/null 2>&1; then
  printf 'docker is required for two-column verbatim checks\n' >&2
  exit 1
fi

if ! docker image inspect "${IMAGE}" >/dev/null 2>&1; then
  printf 'Missing image %s. Build it with: docker build -t %s .\n' "${IMAGE}" "${IMAGE}" >&2
  exit 1
fi

tmp_root="$(mktemp -d)"
trap 'rm -rf "${tmp_root}"' EXIT

cp "${REPO_ROOT}/tests/verbatim-twocolumn.md" "${tmp_root}/verbatim-twocolumn.md"

render_log="${tmp_root}/render.log"
docker run --rm -v "${tmp_root}:/work" -w /work "${IMAGE}" \
  /usr/local/bin/panpreposterous verbatim-twocolumn.md -o verbatim-twocolumn.pdf >"${render_log}" 2>&1

if [[ ! -s "${tmp_root}/verbatim-twocolumn.pdf" ]]; then
  printf 'Two-column verbatim fixture failed: expected verbatim-twocolumn.pdf\n' >&2
  cat "${render_log}" >&2
  exit 1
fi

if [[ ! -s "${tmp_root}/verbatim-twocolumn.tex" ]]; then
  printf 'Two-column verbatim fixture failed: expected verbatim-twocolumn.tex\n' >&2
  cat "${render_log}" >&2
  exit 1
fi

grep -Fq '\fvset{' "${tmp_root}/verbatim-twocolumn.tex"
grep -Fq 'breaklines=true' "${tmp_root}/verbatim-twocolumn.tex"
grep -Fq '\begin{Shaded}' "${tmp_root}/verbatim-twocolumn.tex"
grep -Fq '\begin{Highlighting}[]' "${tmp_root}/verbatim-twocolumn.tex"

if grep -Fq 'Environment Shaded undefined' "${render_log}"; then
  printf 'Two-column verbatim fixture failed: Shaded environment remained undefined\n' >&2
  cat "${render_log}" >&2
  exit 1
fi

if grep -Fq 'Overfull \\hbox' "${render_log}"; then
  printf 'Two-column verbatim fixture failed: detected overfull hbox from code block rendering\n' >&2
  cat "${render_log}" >&2
  exit 1
fi

printf 'Two-column verbatim checks passed.\n'
