#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly IMAGE="${IMAGE:-panpreposterous:mermaid}"

if ! command -v docker >/dev/null 2>&1; then
  printf 'docker is required for wide-table cell overflow checks\n' >&2
  exit 1
fi

if ! docker image inspect "${IMAGE}" >/dev/null 2>&1; then
  printf 'Missing image %s. Build it with: docker build -t %s .\n' "${IMAGE}" "${IMAGE}" >&2
  exit 1
fi

tmp_root="$(mktemp -d)"
trap 'rm -rf "${tmp_root}"' EXIT

cp "${REPO_ROOT}/tests/wide-table-cell-overflow.md" "${tmp_root}/wide-table-cell-overflow.md"

render_log="${tmp_root}/render.log"
docker run --rm -v "${tmp_root}:/work" -w /work "${IMAGE}" \
  /usr/local/bin/panpreposterous wide-table-cell-overflow.md -o wide-table-cell-overflow.pdf >"${render_log}" 2>&1

if [[ ! -s "${tmp_root}/wide-table-cell-overflow.pdf" ]]; then
  printf 'Wide-table cell overflow fixture failed: expected wide-table-cell-overflow.pdf\n' >&2
  cat "${render_log}" >&2
  exit 1
fi

if [[ ! -s "${tmp_root}/wide-table-cell-overflow.tex" ]]; then
  printf 'Wide-table cell overflow fixture failed: expected wide-table-cell-overflow.tex\n' >&2
  cat "${render_log}" >&2
  exit 1
fi

grep -Fq '\begin{table*}[tb]' "${tmp_root}/wide-table-cell-overflow.tex"
grep -Fq '\begin{tabularx}{\textwidth}{@{}' "${tmp_root}/wide-table-cell-overflow.tex"
grep -Fq '>{\RaggedRight\arraybackslash}p{' "${tmp_root}/wide-table-cell-overflow.tex"
grep -Fq '\end{tabularx}' "${tmp_root}/wide-table-cell-overflow.tex"
grep -Fq '\end{table*}' "${tmp_root}/wide-table-cell-overflow.tex"

if grep -Fq 'Overfull \\hbox' "${render_log}"; then
  printf 'Wide-table cell overflow fixture failed: detected overfull hbox from table cell content\n' >&2
  cat "${render_log}" >&2
  exit 1
fi

printf 'Wide-table cell overflow checks passed.\n'
