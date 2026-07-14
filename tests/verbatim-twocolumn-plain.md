---
title: "Verbatim Two-Column Plain Fence Fixture"
author:
  - name: "Test Author"
    affiliation: [1]
    corresponding: true
affiliations:
  - id: 1
    name: "Department of Testing, Test University, Test Country"
running_title: "Verbatim Two-Column Plain"
doc_version: "Preprint"
twocolumn: true
keep_intermediate_tex: true
correspondence:
  - test@example.com (T. Author)
---

## Introduction

This fixture validates plain fenced blocks in two-column mode.

```bash
curl -fsSL "https://example.org/some/really/long/path/that/does/not/contain/spaces/and/forces/the/verbatim/renderer/to/wrap/within/the/current/column/width/instead/of/overflowing/into/the/page_margin?token=ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789&another_parameter=abcdefghijklmnopqrstuvwxyz0123456789"
```

<!-- markdownlint-disable-next-line MD040 -->
```
https://example.org/plain-fence/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
```

## References {-}

::: {#refs}
:::
