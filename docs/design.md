# Design Documentation

Design documentation is a core pillar of Continuous Compliance. It explains **how** software
units are implemented — bridging the gap between requirements (what the code must do) and
source code (what the code actually does). Without design documentation, reviewers — both human
and AI — must infer implementation intent from code alone, making thorough compliance review
significantly harder.

## Why Design Documentation Matters

A complete Continuous Compliance evidence chain for any software unit has four layers:

1. **Requirements** — what the unit must do and why (captured in `docs/reqstream/*.yaml`)
2. **Design** — how the unit is structured and the rationale behind key decisions
   (captured in `docs/design/*.md`)
3. **Source code** — what the unit actually does (`src/**/*.cs` or equivalent)
4. **Tests** — which behaviors are verified and how (`test/**/*.cs` or equivalent)

Design documentation is the layer that makes the other three coherent. It describes data models,
class structures, algorithms, method responsibilities, and inter-unit interactions at the level
of detail needed for formal code review. A reviewer reading a design document should be able to
understand the implementation approach without reading every line of code.

## Role in File Reviews

[ReviewMark](https://github.com/demaconsulting/ReviewMark) groups files into review-sets that
cover the complete evidence chain for a feature or software unit. Well-structured design
documentation makes these review-sets far more effective:

- **For human reviewers** — a design document explains the intent behind implementation choices,
  making it possible to assess whether the code correctly realizes the design
- **For AI review agents** — a design document provides the structured context needed to reason
  across requirements, implementation, and tests simultaneously, producing higher-quality and
  more specific review recommendations
- **For auditors** — design documentation proves that the implementation was planned before it
  was built, not just described after the fact

See [File Reviews](file-reviews.md) for the full documentation on ReviewMark configuration and
review-set organization.

## Design Document Types

A typical Continuous Compliance project uses three levels of design documentation, each serving
a distinct role in the review evidence chain:

### Design Introduction (`docs/design/introduction.md`)

The introduction is the entry point for the entire design. It provides:

- **Purpose** — why this design documentation exists and what it covers
- **Scope** — which software units are described and what is explicitly excluded
- **Software structure** — a tree showing how units are organized across subsystem and unit levels
- **Folder layout** — a mapping from design documents to source files so reviewers can navigate
  from design to implementation

Every project should have exactly one `introduction.md`. It is the document a reviewer or agent
reads first when beginning a design review.

### System Design (`docs/design/system.md`)

The system design describes how the software units work together as an integrated whole. In real
projects this file is named `system.md`; the template uses `example-system.md` to make it clear
the file is an example rather than production documentation:

- **System data flow** — the direction of data between units during key operations
- **Processing pipeline** — the end-to-end sequence of operations across units
- **Interactions between units** — a table of inter-unit calls, call sites, and purpose

A system design document is most valuable for projects with multiple units that coordinate to
deliver system-level behavior. For simple systems where units are entirely independent, this
document can be brief.

### Unit Design (`docs/design/{unit}.md`)

Each software unit has its own design document. A unit design covers:

- **Overview** — the unit's role and responsibilities in one or two sentences
- **Design decisions** — key implementation choices and their rationale
- **Data models** — class structure, properties, and key types
- **Method descriptions** — the behavior of each public method and how it satisfies requirements
- **Interactions** — which other units this unit calls and which units call it

Unit design documents are the primary evidence that links requirements to implementation during
per-unit reviews.

## Standard Folder Layout

All design documentation lives under `docs/design/`:

```text
docs/design/
├── introduction.md      — design overview, scope, and structure (always required)
├── system.md            — system-level data flows and unit interactions
├── {component}.md       — one file per software unit (class or module)
└── {subsystem}.md       — optional subsystem-level design documents
```

This layout is referenced in the [Technical Documentation Standards][tech-doc] used by DEMA
Consulting and aligns with the folder structure expected by ReviewMark review-sets.

[tech-doc]: https://raw.githubusercontent.com/demaconsulting/TemplateDotNetLibrary/refs/heads/main/.github/standards/technical-documentation.md

## Connecting Design to ReviewMark

Design documentation integrates directly into ReviewMark review-sets. The standard review-set
types defined in DEMA Consulting projects include design documents at the appropriate scope:

| Review-Set Type | Design Files Included |
| :-------------- | :-------------------- |
| **System** | `docs/design/introduction.md`, `docs/design/system.md` |
| **Design** | `docs/design/**/*.md` (all design documents) |
| **Unit** | `docs/design/{unit}.md` (single unit design document) |

A `.reviewmark.yaml` that includes design documentation at each scope level:

```yaml
reviews:
  - id: MyProduct-System
    title: System Integration Review
    paths:
      - "docs/reqstream/myproduct-system.yaml"
      - "docs/design/introduction.md"
      - "docs/design/system.md"
      - "tests/**/IntegrationTests.cs"

  - id: MyProduct-Design
    title: Architecture and Design Review
    paths:
      - "docs/reqstream/myproduct-system.yaml"
      - "docs/reqstream/platform-requirements.yaml"
      - "docs/design/**/*.md"

  - id: MyProduct-MyComponent
    title: MyComponent Unit Review
    paths:
      - "docs/reqstream/unit-mycomponent.yaml"
      - "docs/design/mycomponent.md"
      - "src/MyComponent.cs"
      - "tests/MyComponentTests.cs"
```

## Template Examples

The [`templates/reviews`](https://github.com/demaconsulting/ContinuousCompliance/tree/main/templates/reviews)
folder contains ready-to-use examples of each design document type:

| Template File | Description |
| :------------ | :---------- |
| [`docs/design/introduction.md`](https://github.com/demaconsulting/ContinuousCompliance/blob/main/templates/reviews/docs/design/introduction.md) | Design introduction for the example system |
| [`docs/design/example-system.md`](https://github.com/demaconsulting/ContinuousCompliance/blob/main/templates/reviews/docs/design/example-system.md) | System-level design showing unit interactions |
| [`docs/design/math-helper-design.md`](https://github.com/demaconsulting/ContinuousCompliance/blob/main/templates/reviews/docs/design/math-helper-design.md) | Unit-level design for `MathHelper` |
| [`docs/design/string-helper-design.md`](https://github.com/demaconsulting/ContinuousCompliance/blob/main/templates/reviews/docs/design/string-helper-design.md) | Unit-level design for `StringHelper` |

The template `.reviewmark.yaml` shows how System, Design, and Unit review-sets reference these
documents alongside requirements, source code, and tests.

## Writing Guidelines

Follow these practices when writing design documentation for Continuous Compliance projects:

- **Describe intent, not mechanism** — explain why a design decision was made, not just what
  the code does; the code itself is the authoritative record of what it does
- **Keep it synchronized** — design documentation reviewed by ReviewMark becomes stale when
  files change; update design documents when implementation changes so reviews stay current
- **Link to requirements** — reference requirement IDs where a design decision directly
  satisfies a specific requirement, making the requirements-to-design traceability explicit
- **Use tables for interactions** — tabular interaction descriptions are more readable than
  prose for reviewers scanning a design document, and process more cleanly by AI agents
- **Be specific** — concrete method names, class names, and data types are more useful than
  abstract descriptions; reviewers need enough detail to verify the implementation
