#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

tmp_latex="$(mktemp)"
tmp_stderr="$(mktemp)"
trap 'rm -f "${tmp_latex}" "${tmp_stderr}"' EXIT

pandoc "${REPO_ROOT}/tests/fullwidth-table.md" \
  -t latex \
  --lua-filter="${REPO_ROOT}/filters/backmatter.lua" \
  >"${tmp_latex}" \
  2>"${tmp_stderr}"

grep -Fq '\begin{table*}[tb]' "${tmp_latex}"
grep -Fq '\caption{\textbf{Full-width table regression.} This caption should be preserved.}' "${tmp_latex}"
grep -Fq '\label{tbl:fullwidth-regression}' "${tmp_latex}"
grep -Fq '\end{table*}' "${tmp_latex}"

if grep -Fq '\onecolumn' "${tmp_latex}"; then
  printf 'fullwidth regression emitted one-column island\n' >&2
  exit 1
fi

if grep -Fq 'Markdown table suppressed' "${tmp_latex}" || grep -Fq 'Markdown table suppressed' "${tmp_stderr}"; then
  printf 'fullwidth regression suppressed the table\n' >&2
  exit 1
fi

printf 'Full-width markdown table regression passed.\n'
