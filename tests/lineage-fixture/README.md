# Lineage Fixture Inputs

This directory contains lightweight fixture files used by
scripts/verify-lineage-scaffold.sh.

- help-sections.txt: expected section headings in wrapper help output
- runtime-assets.txt: repo-relative runtime assets that must exist
- ../check-fullwidth-table.sh: regression check for the `.fullwidth` markdown
  table contract
- ../fullwidth-table.md: markdown fixture used by the full-width table check
- ../check-mermaid-phase5.sh: Mermaid Phase 5 validation harness
- ../check-intermediate-tex.sh: intermediate TeX sidecar validation harness
- ../mermaid-types.md: diagram-type and wide-float fixture
- ../mermaid-supplementary.md: supplementary compatibility fixture
- ../mermaid-invalid.md: invalid Mermaid fallback fixture
- ../intermediate-tex-enabled.md: fixture with `keep_intermediate_tex: true`
- ../intermediate-tex-disabled.md: fixture with default sidecar-disabled behavior

Fixture files are intentionally small so they can evolve with the repository
without introducing heavy snapshot maintenance.
