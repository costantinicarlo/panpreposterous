#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly IMAGE="panpreposterous:mermaid"

if ! command -v docker >/dev/null 2>&1; then
  printf 'docker is required for intermediate TeX checks\n' >&2
  exit 1
fi

if ! docker image inspect "${IMAGE}" >/dev/null 2>&1; then
  printf 'Missing image %s. Build it with: docker build -t %s .\n' "${IMAGE}" "${IMAGE}" >&2
  exit 1
fi

tmp_root="$(mktemp -d)"
trap 'rm -rf "${tmp_root}"' EXIT

cp "${REPO_ROOT}/tests/intermediate-tex-enabled.md" "${tmp_root}/enabled.md"
cp "${REPO_ROOT}/tests/intermediate-tex-disabled.md" "${tmp_root}/disabled.md"

# 1) Enabled key should emit both PDF and TeX output.
docker run --rm -v "${tmp_root}:/work" -w /work "${IMAGE}" \
  /usr/local/bin/panpreposterous enabled.md -o enabled-output.pdf

if [[ ! -s "${tmp_root}/enabled-output.pdf" ]]; then
  printf 'Enabled fixture failed: expected enabled-output.pdf\n' >&2
  exit 1
fi

if [[ ! -s "${tmp_root}/enabled-output.tex" ]]; then
  printf 'Enabled fixture failed: expected enabled-output.tex\n' >&2
  exit 1
fi

grep -Fq '\begin{document}' "${tmp_root}/enabled-output.tex"

# 2) Default behavior should not emit TeX sidecar.
docker run --rm -v "${tmp_root}:/work" -w /work "${IMAGE}" \
  /usr/local/bin/panpreposterous disabled.md -o disabled-output.pdf

if [[ ! -s "${tmp_root}/disabled-output.pdf" ]]; then
  printf 'Disabled fixture failed: expected disabled-output.pdf\n' >&2
  exit 1
fi

if [[ -e "${tmp_root}/disabled-output.tex" ]]; then
  printf 'Disabled fixture failed: unexpected disabled-output.tex\n' >&2
  exit 1
fi

printf 'Intermediate TeX checks passed.\n'
