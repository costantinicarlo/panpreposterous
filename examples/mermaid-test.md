---
title: "Mermaid Diagram Test Manuscript"
author:
  - name: "Test Author"
    affiliation: [1]
    corresponding: true
affiliations:
  - id: 1
    name: "Department of Testing, Test University, Test Country"
running_title: "Mermaid Test"
doc_version: "Preprint"
twocolumn: true
correspondence:
  - test@example.com (T. Author)
abstract: "This manuscript tests the rendering of Mermaid diagrams in panpreposterous. It includes examples of flowcharts, sequence diagrams, and state diagrams."
keywords: ["Mermaid", "diagrams", "testing"]
---

# Introduction

This test document demonstrates the new Mermaid diagram rendering capability in panpreposterous.

# Methods

## Flowchart Example

Here is a simple flowchart showing a decision process:

```mermaid
flowchart TD
    Start([Start Analysis]) --> Load["Load Data"]
    Load --> Validate{Valid Data?}
    Validate -->|No| Error["Report Error"]
    Error --> End([End])
    Validate -->|Yes| Process["Process Data"]
    Process --> Output["Generate Output"]
    Output --> End
```

## Sequence Diagram Example

Here is a sequence diagram showing interaction between components:

```mermaid
sequenceDiagram
    participant User
    participant System
    participant Database
    
    User ->> System: Request data
    activate System
    System ->> Database: Query
    activate Database
    Database -->> System: Return results
    deactivate Database
    System ->> System: Process results
    System -->> User: Send response
    deactivate System
```

## State Diagram Example

Here is a state machine diagram:

```mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> Processing: trigger
    Processing --> Done: complete
    Done --> [*]
    Processing --> Error: error
    Error --> Idle: reset
```

# Results

All diagrams should render correctly in the PDF output.

# Discussion

The Mermaid diagram rendering feature allows authors to:
- Include diagrams directly in Markdown
- Maintain version control of diagram definitions
- Keep technical documentation and diagrams together
- Avoid external image file management

# References {-}

::: {#refs}
:::
