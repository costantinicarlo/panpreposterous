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
- ../check-font-compatibility.sh: Unicode and font fallback validation harness
- ../mermaid-types.md: diagram-type and wide-float fixture
- ../mermaid-supplementary.md: supplementary compatibility fixture
- ../mermaid-invalid.md: invalid Mermaid fallback fixture
- ../intermediate-tex-enabled.md: fixture with `keep_intermediate_tex: true`
- ../intermediate-tex-disabled.md: fixture with default sidecar-disabled behavior
- ../font-unicode-default.md: default-font Unicode compatibility fixture
- ../font-unicode-custom.md: explicit runtime-font compatibility fixture
- ../font-unicode-missingfont.md: missing-font fallback fixture

Fixture files are intentionally small so they can evolve with the repository
without introducing heavy snapshot maintenance.
