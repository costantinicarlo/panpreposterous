---
title: "Verbatim One-Column Fixture"
author:
  - name: "Test Author"
    affiliation: [1]
    corresponding: true
affiliations:
  - id: 1
    name: "Department of Testing, Test University, Test Country"
running_title: "Verbatim One-Column"
doc_version: "Preprint"
twocolumn: false
keep_intermediate_tex: true
correspondence:
  - test@example.com (T. Author)
---

## Introduction

This fixture validates language-tagged and plain fenced code blocks in one-column mode.

```bash
echo "language-tagged fence should compile with highlighting enabled"
```

<!-- markdownlint-disable-next-line MD040 -->
```
plain fence should compile without requiring a language tag
```

## References {-}

::: {#refs}
:::
