---
twocolumn: true
---

# Mermaid Type Coverage Fixture

Phase 5 Mermaid type-coverage fixture.

```mermaid
classDiagram
  class Animal {
    +String name
    +eat()
  }
  class Dog {
    +bark()
  }
  Animal <|-- Dog
```

```mermaid
erDiagram
  AUTHOR ||--o{ PAPER : writes
  PAPER ||--o{ FIGURE : contains
```

```mermaid
gantt
  title Project Timeline
  dateFormat  YYYY-MM-DD
  section Core
  Implement filter :done, des1, 2026-06-01, 2026-06-08
  Validate output  :active, des2, 2026-06-09, 2026-06-15
```

```mermaid
pie title Mermaid Rendering Outcomes
  "Rendered" : 92
  "Fallback" : 8
```

```{.mermaid .fullwidth caption="Wide sequence diagram for two-column figure-star policy." label="fig:phase5-wide"}
sequenceDiagram
  participant Author
  participant Build
  participant PDF
  Author->>Build: Trigger render
  Build->>PDF: Include figure assets
  PDF-->>Author: Two-column output
```
