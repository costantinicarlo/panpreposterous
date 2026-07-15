#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly IMAGE="panpreposterous:mermaid"

if ! command -v docker >/dev/null 2>&1; then
  printf 'docker is required for many-column wide table checks\n' >&2
  exit 127
fi

if ! docker image inspect "${IMAGE}" >/dev/null 2>&1; then
  printf 'Missing image %s. Build it with: docker build -t %s .\n' "${IMAGE}" "${IMAGE}" >&2
  exit 1
fi

tmp_latex="$(mktemp)"
tmp_stderr="$(mktemp)"
trap 'rm -f "${tmp_latex}" "${tmp_stderr}"' EXIT

docker run --rm -v "${REPO_ROOT}:/repo" -w /repo "${IMAGE}" \
  pandoc tests/many-column-wide-table.md \
  -t latex \
  --lua-filter=filters/backmatter.lua \
  >"${tmp_latex}" \
  2>"${tmp_stderr}"

grep -Fq '\begin{table*}[tb]' "${tmp_latex}"
grep -Fq '\begin{tabularx}{\textwidth}{@{}' "${tmp_latex}"
grep -Fq '>{\RaggedRight\arraybackslash}p{' "${tmp_latex}"
grep -Fq '\caption{\textbf{Many-column wide table regression.} Full-width table should stay within page width in two-column output.}' "${tmp_latex}"
grep -Fq '\label{tbl:many-column-wide}' "${tmp_latex}"
grep -Fq '\end{tabularx}' "${tmp_latex}"
grep -Fq '\end{table*}' "${tmp_latex}"

if grep -Fq '\onecolumn' "${tmp_latex}"; then
  printf 'many-column full-width regression emitted one-column island\n' >&2
  exit 1
fi

if grep -Fq 'Markdown table suppressed' "${tmp_latex}" || grep -Fq 'Markdown table suppressed' "${tmp_stderr}"; then
  printf 'many-column full-width regression suppressed the table\n' >&2
  exit 1
fi

printf 'Many-column full-width table regression passed.\n'
