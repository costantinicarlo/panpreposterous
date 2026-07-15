#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly IMAGE="${IMAGE:-panpreposterous:mermaid}"

if ! command -v docker >/dev/null 2>&1; then
  printf 'docker is required for mixed-density wide table checks\n' >&2
  exit 1
fi

if ! docker image inspect "${IMAGE}" >/dev/null 2>&1; then
  printf 'Missing image %s. Build it with: docker build -t %s .\n' "${IMAGE}" "${IMAGE}" >&2
  exit 1
fi

tmp_latex="$(mktemp)"
tmp_stderr="$(mktemp)"
trap 'rm -f "${tmp_latex}" "${tmp_stderr}"' EXIT

if ! docker run --rm -v "${REPO_ROOT}:/repo" -w /repo "${IMAGE}" \
    pandoc tests/mixed-density-wide-table.md \
    -t latex \
    --lua-filter=filters/backmatter.lua \
    >"${tmp_latex}" \
    2>"${tmp_stderr}"; then
  printf 'Mixed-density regression failed while generating LaTeX with image %s\n' "${IMAGE}" >&2
  cat "${tmp_stderr}" >&2
  exit 1
fi

grep -Fq '\begin{table*}[tb]' "${tmp_latex}"
grep -Fq '\begin{tabularx}{\textwidth}{@{}' "${tmp_latex}"
grep -Fq '@{}>{\RaggedRight\arraybackslash}p{' "${tmp_latex}"
grep -Fq '\end{table*}' "${tmp_latex}"

widths="$(perl -ne 'while (/p\{([0-9.]+)\\linewidth\}/g) { print "$1 " }' "${tmp_latex}")"
set -- ${widths}

if [[ "$#" -ne 4 ]]; then
  printf 'Mixed-density regression failed: expected four fixed column widths, found %s\n' "$#" >&2
  cat "${tmp_latex}" >&2
  exit 1
fi

if ! awk -v sparse_id="$1" -v dense_workflow="$2" -v sparse_flag="$3" -v dense_action="$4" \
  'BEGIN { exit !((dense_workflow > sparse_id) && (dense_action > sparse_flag)) }'; then
  printf 'Mixed-density regression failed: dense columns were not wider than sparse columns\n' >&2
  cat "${tmp_latex}" >&2
  exit 1
fi

if ! awk -v w1="$1" -v w2="$2" -v w3="$3" -v w4="$4" \
  'BEGIN { total = w1 + w2 + w3 + w4; exit !(total >= 0.959 && total <= 0.961) }'; then
  printf 'Mixed-density regression failed: allocated widths did not sum to the safe 0.96 target\n' >&2
  cat "${tmp_latex}" >&2
  exit 1
fi

if grep -Fq 'Markdown table suppressed' "${tmp_latex}" || grep -Fq 'Markdown table suppressed' "${tmp_stderr}"; then
  printf 'Mixed-density regression suppressed the table\n' >&2
  exit 1
fi

printf 'Mixed-density wide table regression passed.\n'
