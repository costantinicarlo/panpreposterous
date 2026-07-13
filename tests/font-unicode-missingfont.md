---
title: "Missing Font Fallback"
author:
  - name: "Fixture Author"
    affiliation: [1]
affiliations:
  - id: 1
    name: "Fixture Lab"
running_title: "Missing Font"
doc_version: "Preprint"
twocolumn: false
correspondence:
  - fixture@example.org
keep_intermediate_tex: true
mainfont: "Imaginary Serif Font"
sansfont: "Imaginary Sans Font"
monofont: "Imaginary Mono Font"
---

# Introduction

This fixture verifies graceful fallback when requested fonts are unavailable.

Expected: PDF build succeeds with fallback fonts and emits template warnings.

# References {-}
::: {#refs}
:::
