#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly IMAGE="panpreposterous:mermaid"

if ! command -v docker >/dev/null 2>&1; then
  printf 'docker is required for supplementary-list checks\n' >&2
  exit 1
fi

if ! docker image inspect "${IMAGE}" >/dev/null 2>&1; then
  printf 'Missing image %s. Build it with: docker build -t %s .\n' "${IMAGE}" "${IMAGE}" >&2
  exit 1
fi

tmp_root="$(mktemp -d)"
trap 'rm -rf "${tmp_root}"' EXIT

md_latex="${tmp_root}/supplementary-markdown.tex"
raw_latex="${tmp_root}/supplementary-raw-starred.tex"
mermaid_latex="${tmp_root}/supplementary-mermaid-starred.tex"

# 1) Markdown figure + markdown table should generate both supplementary lists.
docker run --rm -v "${REPO_ROOT}:/repo" -w /repo "${IMAGE}" \
  pandoc tests/supplementary-markdown-lists.md -t latex \
  --lua-filter=filters/supplementary.lua \
  >"${md_latex}"

grep -Fq '\subsection*{List of Supplementary Figures}' "${md_latex}"
grep -Fq '\subsection*{List of Supplementary Tables}' "${md_latex}"
grep -Fq 'Supplementary Figure S1.' "${md_latex}"
grep -Fq 'Supplementary Table S1.' "${md_latex}"

# 2) Raw LaTeX figure* and table* should also generate lists and refs.
docker run --rm -v "${REPO_ROOT}:/repo" -w /repo "${IMAGE}" \
  pandoc tests/supplementary-raw-starred-floats.md -t latex \
  --lua-filter=filters/supplementary.lua \
  >"${raw_latex}"

grep -Fq '\subsection*{List of Supplementary Figures}' "${raw_latex}"
grep -Fq '\subsection*{List of Supplementary Tables}' "${raw_latex}"
grep -Fq '\ref{fig:s-raw-star}' "${raw_latex}"
grep -Fq '\ref{tbl:s-raw-star}' "${raw_latex}"

# 3) Mermaid .fullwidth in supplementary should be counted as a starred figure.
docker run --rm -v "${REPO_ROOT}:/repo" -w /repo "${IMAGE}" \
  pandoc tests/supplementary-mermaid-starred.md -t latex \
  --lua-filter=filters/mermaid.lua \
  --lua-filter=filters/supplementary.lua \
  >"${mermaid_latex}"

grep -Fq '\subsection*{List of Supplementary Figures}' "${mermaid_latex}"
grep -Fq 'Starred Mermaid supplementary figure.' "${mermaid_latex}"
grep -Fq '\ref{fig:s-mermaid-star}' "${mermaid_latex}"

printf 'Supplementary list contract checks passed.\n'
