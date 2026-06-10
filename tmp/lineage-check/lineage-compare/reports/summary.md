## Phase 2 Image Comparison Summary

- Legacy image: docker.io/costantinicarlo/panpreposterous:1.0
- Candidate image: panpreposterous

Generated reports:

- payload diff: ./tmp/lineage-check/lineage-compare/reports/payload.diff
- help diff: ./tmp/lineage-check/lineage-compare/reports/help.diff
- render diff: ./tmp/lineage-check/lineage-compare/reports/render.diff
- legacy render metadata: ./tmp/lineage-check/lineage-compare/reports/legacy-render/legacy-render.txt
- candidate render metadata: ./tmp/lineage-check/lineage-compare/reports/candidate-render/candidate-render.txt

Interpretation rules:

- An empty  means the extracted wrapper, template, and filter payloads match.
- An empty  means the CLI help text matches.
- An empty  means the smoke-render output metadata matches.
- Non-empty diffs do not automatically block release, but they must be reviewed
  before publishing a successor image.
