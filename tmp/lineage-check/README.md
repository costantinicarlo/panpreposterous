# Lineage Check Workspace Contract

This directory is a local workspace for lineage comparison and check outputs.

Tracked scaffold:

- tmp/lineage-check/lineage-compare/candidate/.gitkeep
- tmp/lineage-check/lineage-compare/legacy/.gitkeep
- tmp/lineage-check/lineage-compare/reports/.gitkeep

Ownership model:

- candidate/: unpacked artifacts from current workspace builds
- legacy/: unpacked artifacts from legacy baseline images
- reports/: generated comparison and verification outputs

Generated files under candidate/, legacy/, and reports/ are intentionally not
tracked.

The scaffold is tracked so local tooling can rely on stable paths while
preserving a clean git history for generated outputs.
