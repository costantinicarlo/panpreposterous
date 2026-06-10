#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

HELP_SECTIONS_FIXTURE="${REPO_ROOT}/tests/lineage-fixture/help-sections.txt"
RUNTIME_ASSETS_FIXTURE="${REPO_ROOT}/tests/lineage-fixture/runtime-assets.txt"
TMP_ROOT="${REPO_ROOT}/tmp/lineage-check"
REPORT_DIR="${TMP_ROOT}/lineage-compare/reports"

require_file() {
  local path="$1"
  if [[ ! -f "${path}" ]]; then
    printf 'Missing required file: %s\n' "${path}" >&2
    return 1
  fi
}

require_dir() {
  local path="$1"
  if [[ ! -d "${path}" ]]; then
    printf 'Missing required directory: %s\n' "${path}" >&2
    return 1
  fi
}

check_runtime_assets() {
  while IFS= read -r rel_path; do
    [[ -z "${rel_path}" ]] && continue
    [[ "${rel_path}" =~ ^# ]] && continue
    require_file "${REPO_ROOT}/${rel_path}"
  done < "${RUNTIME_ASSETS_FIXTURE}"
}

check_help_sections() {
  local help_output
  help_output="$(bash "${REPO_ROOT}/bin/panpreposterous" --help)"

  while IFS= read -r heading; do
    [[ -z "${heading}" ]] && continue
    [[ "${heading}" =~ ^# ]] && continue
    if ! printf '%s\n' "${help_output}" | grep -q "^${heading}$"; then
      printf 'Missing help heading: %s\n' "${heading}" >&2
      return 1
    fi
  done < "${HELP_SECTIONS_FIXTURE}"
}

check_tmp_contract() {
  require_file "${TMP_ROOT}/README.md"
  require_dir "${TMP_ROOT}/lineage-compare"
  require_dir "${TMP_ROOT}/lineage-compare/candidate"
  require_dir "${TMP_ROOT}/lineage-compare/legacy"
  require_dir "${TMP_ROOT}/lineage-compare/reports"
}

write_report() {
  mkdir -p "${REPORT_DIR}"
  local report_file="${REPORT_DIR}/latest-structure-check.txt"
  {
    printf 'lineage scaffold check: ok\n'
    printf 'timestamp_utc=%s\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    printf 'repo_root=%s\n' "${REPO_ROOT}"
  } > "${report_file}"
  printf 'Report written: %s\n' "${report_file}"
}

main() {
  require_file "${HELP_SECTIONS_FIXTURE}"
  require_file "${RUNTIME_ASSETS_FIXTURE}"

  check_runtime_assets
  check_help_sections
  check_tmp_contract
  write_report

  printf 'Lineage scaffold verification passed.\n'
}

main "$@"
