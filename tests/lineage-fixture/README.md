# Lineage Fixture Inputs

This directory contains lightweight fixture files used by
scripts/verify-lineage-scaffold.sh.

- help-sections.txt: expected section headings in wrapper help output
- runtime-assets.txt: repo-relative runtime assets that must exist
- ../check-fullwidth-table.sh: regression check for the `.fullwidth` markdown
  table contract
- ../fullwidth-table.md: markdown fixture used by the full-width table check

Fixture files are intentionally small so they can evolve with the repository
without introducing heavy snapshot maintenance.
