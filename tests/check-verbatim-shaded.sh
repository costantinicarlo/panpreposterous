#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly IMAGE="panpreposterous:mermaid"

if ! command -v docker >/dev/null 2>&1; then
  printf 'docker is required for shaded/verbatim checks\n' >&2
  exit 1
fi

if ! docker image inspect "${IMAGE}" >/dev/null 2>&1; then
  printf 'Missing image %s. Build it with: docker build -t %s .\n' "${IMAGE}" "${IMAGE}" >&2
  exit 1
fi

tmp_root="$(mktemp -d)"
trap 'rm -rf "${tmp_root}"' EXIT

cp "${REPO_ROOT}/tests/verbatim-onecolumn.md" "${tmp_root}/verbatim-onecolumn.md"
cp "${REPO_ROOT}/tests/verbatim-twocolumn.md" "${tmp_root}/verbatim-twocolumn.md"

run_fixture() {
  local source_md="$1"
  local out_base="$2"

  local render_log="${tmp_root}/${out_base}.log"
  docker run --rm -v "${tmp_root}:/work" -w /work "${IMAGE}" \
    /usr/local/bin/panpreposterous "${source_md}" -o "${out_base}.pdf" >"${render_log}" 2>&1

  if [[ ! -s "${tmp_root}/${out_base}.pdf" ]]; then
    printf 'Verbatim fixture failed: expected %s.pdf\n' "${out_base}" >&2
    cat "${render_log}" >&2
    exit 1
  fi

  if [[ ! -s "${tmp_root}/${out_base}.tex" ]]; then
    printf 'Verbatim fixture failed: expected %s.tex\n' "${out_base}" >&2
    cat "${render_log}" >&2
    exit 1
  fi

  grep -Fq '\begin{Shaded}' "${tmp_root}/${out_base}.tex"

  if grep -Fq 'Environment Shaded undefined' "${render_log}"; then
    printf 'Verbatim fixture failed: Shaded environment remained undefined for %s\n' "${out_base}" >&2
    cat "${render_log}" >&2
    exit 1
  fi
}

# One-column: validate both language-tagged and plain fences compile.
run_fixture verbatim-onecolumn.md verbatim-onecolumn
if ! grep -Fq '\begin{verbatim}' "${tmp_root}/verbatim-onecolumn.tex" && ! grep -Fq '\begin{Verbatim}' "${tmp_root}/verbatim-onecolumn.tex"; then
  printf 'Verbatim one-column fixture failed: plain fence did not emit a verbatim environment\n' >&2
  exit 1
fi

grep -Fq '\begin{Highlighting}[]' "${tmp_root}/verbatim-onecolumn.tex"

# Two-column: validate wrapping/scaffolding remain in place.
run_fixture verbatim-twocolumn.md verbatim-twocolumn

grep -Fq '\fvset{' "${tmp_root}/verbatim-twocolumn.tex"
grep -Fq 'breaklines=true' "${tmp_root}/verbatim-twocolumn.tex"

if grep -Fq 'Overfull \\hbox' "${tmp_root}/verbatim-twocolumn.log"; then
  printf 'Verbatim two-column fixture failed: detected overfull hbox\n' >&2
  cat "${tmp_root}/verbatim-twocolumn.log" >&2
  exit 1
fi

printf 'Shaded and verbatim compatibility checks passed.\n'
