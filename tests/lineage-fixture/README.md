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
- ../check-verbatim-twocolumn.sh: two-column verbatim wrapping validation harness
- ../check-verbatim-shaded.sh: shaded/highlighting compatibility harness for plain and language-tagged fences
- ../check-verbatim-twocolumn-plain.sh: two-column plain-fence wrapping harness for untagged verbatim blocks
- ../check-verbatim-fontsize.sh: regression harness validating 1pt-down verbatim typography defaults
- ../check-citation-input-modes.sh: citation input parity harness for flag-based and metadata-first bibliography/CSL configuration
- ../check-references-heading-contract.sh: references-heading contract harness for refs anchor and manual heading behaviour
- ../check-supplementary-list-contract.sh: supplementary list-generation harness for markdown, raw LaTeX starred floats, and Mermaid full-width output
- ../check-many-column-wide-table.sh: regression harness for many-column full-width markdown tables staying within page width
- ../check-wide-table-cell-overflow.sh: regression harness for dense wide-table cell content remaining within page bounds
- ../check-hyperlink-colors.sh: regression harness for default hyperref text-link colours and border suppression
- ../mermaid-types.md: diagram-type and wide-float fixture
- ../mermaid-supplementary.md: supplementary compatibility fixture
- ../mermaid-invalid.md: invalid Mermaid fallback fixture
- ../intermediate-tex-enabled.md: fixture with `keep_intermediate_tex: true`
- ../intermediate-tex-disabled.md: fixture with default sidecar-disabled behavior
- ../font-unicode-default.md: default-font Unicode compatibility fixture
- ../font-unicode-custom.md: explicit runtime-font compatibility fixture
- ../font-unicode-missingfont.md: missing-font fallback fixture
- ../verbatim-onecolumn.md: one-column fixture with language-tagged and plain fences
- ../verbatim-twocolumn.md: two-column long-line verbatim fixture
- ../verbatim-twocolumn-plain.md: two-column fixture validating long untagged fenced blocks
- ../verbatim-fontsize.md: fixture validating fenced-block font-size defaults for tagged and plain fences
- ../metadata-citation-inputs.md: metadata-first citation fixture used to validate bibliography/CSL YAML inputs
- ../references-metadata-only.md: fixture validating refs anchor insertion without a manual heading
- ../references-manual-only.md: fixture validating manual references heading with refs anchor
- ../references-manual-plus-metadata.md: fixture validating duplicate-heading guard when manual heading and metadata key coexist
- ../supplementary-markdown-lists.md: fixture validating supplementary lists from markdown figure and markdown table content
- ../supplementary-raw-starred-floats.md: fixture validating supplementary lists from raw LaTeX `figure*` and `table*` floats
- ../supplementary-mermaid-starred.md: fixture validating supplementary list generation for `.fullwidth` Mermaid output inside supplementary content
- ../many-column-wide-table.md: fixture validating overflow-resistant rendering for high-column-count full-width markdown tables
- ../wide-table-cell-overflow.md: fixture validating dense cell-content wrapping in full-width markdown tables
- ../hyperlink-colors.md: fixture validating default hyperlink colour setup and cite/url/internal link rendering

Fixture files are intentionally small so they can evolve with the repository
without introducing heavy snapshot maintenance.
