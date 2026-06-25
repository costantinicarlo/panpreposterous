#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly IMAGE="panpreposterous:mermaid"

if ! command -v docker >/dev/null 2>&1; then
  printf 'docker is required for Phase 5 Mermaid checks\n' >&2
  exit 1
fi

if ! docker image inspect "${IMAGE}" >/dev/null 2>&1; then
  printf 'Missing image %s. Build it with: docker build -t %s .\n' "${IMAGE}" "${IMAGE}" >&2
  exit 1
fi

tmp_root="$(mktemp -d)"
trap 'rm -rf "${tmp_root}"' EXIT

types_latex="${tmp_root}/mermaid-types.tex"
supp_latex="${tmp_root}/mermaid-supplementary.tex"
invalid_latex="${tmp_root}/mermaid-invalid.tex"
types_cache="${tmp_root}/mermaid-cache"
out_pdf_dir="${REPO_ROOT}/tmp/phase5-mermaid"
out_pdf="${out_pdf_dir}/manuscript-phase5.pdf"

mkdir -p "${out_pdf_dir}"
mkdir -p "${types_cache}"
rm -f "${out_pdf}"

# 1) Diagram type coverage + two-column wide float policy.
docker run --rm -v "${REPO_ROOT}:/repo" -v "${types_cache}:/tmp/panpreposterous_mermaid" -w /repo "${IMAGE}" \
  pandoc tests/mermaid-types.md -t latex --lua-filter=filters/mermaid.lua \
  >"${types_latex}"

if grep -Fq '[Mermaid diagram rendering failed]' "${types_latex}"; then
  printf 'Type coverage fixture produced Mermaid fallback unexpectedly\n' >&2
  exit 1
fi

grep -Fq '\begin{figure*}[!t]' "${types_latex}"

include_count="$(grep -c '\includegraphics' "${types_latex}" || true)"
if [[ "${include_count}" -lt 5 ]]; then
  printf 'Expected at least 5 rendered Mermaid figures, found %s\n' "${include_count}" >&2
  exit 1
fi

if ! grep -Fq 'fill:#ffffff' "${types_cache}"/*.svg; then
  printf 'Expected rendered Mermaid SVGs to use white default node fill\n' >&2
  exit 1
fi

if ! grep -Eq '(fill|color):#111827' "${types_cache}"/*.svg; then
  printf 'Expected rendered Mermaid SVGs to use dark default label text\n' >&2
  exit 1
fi

if grep -Fq '<foreignObject' "${types_cache}"/*.svg; then
  printf 'Expected rendered Mermaid SVGs to avoid foreignObject labels for PDF conversion\n' >&2
  exit 1
fi

if ! grep -Fq '<text' "${types_cache}"/*.svg; then
  printf 'Expected rendered Mermaid SVGs to contain SVG text labels\n' >&2
  exit 1
fi

# 2) Supplementary compatibility (mermaid + supplementary filters together).
docker run --rm -v "${REPO_ROOT}:/repo" -w /repo "${IMAGE}" \
  pandoc tests/mermaid-supplementary.md -t latex \
  --lua-filter=filters/mermaid.lua \
  --lua-filter=filters/supplementary.lua \
  >"${supp_latex}"

grep -Fq '\includegraphics' "${supp_latex}"

# 3) Error handling: invalid Mermaid must degrade gracefully.
docker run --rm -v "${REPO_ROOT}:/repo" -w /repo "${IMAGE}" \
  pandoc tests/mermaid-invalid.md -t latex --lua-filter=filters/mermaid.lua \
  >"${invalid_latex}"

grep -Fq '[Mermaid diagram rendering failed]' "${invalid_latex}"

# 4) Backward compatibility: existing example manuscript still renders.
docker run --rm -v "${REPO_ROOT}:/repo" -w /repo/examples "${IMAGE}" \
  /usr/local/bin/panpreposterous manuscript.md \
  --bibliography references.bib --csl journal.csl -o /repo/tmp/phase5-mermaid/manuscript-phase5.pdf

if [[ ! -s "${out_pdf}" ]]; then
  printf 'Backward compatibility check failed: output PDF missing or empty\n' >&2
  exit 1
fi

printf 'Mermaid Phase 5 checks passed.\n'
printf 'Rendered compatibility PDF: %s\n' "${out_pdf}"
