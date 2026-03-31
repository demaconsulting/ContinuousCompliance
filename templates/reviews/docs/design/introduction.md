# Introduction

This document provides the detailed design for the TemplateReviews example system, a pair of static
utility classes for common arithmetic and string operations.

## Purpose

The purpose of this document is to describe the internal design of each software unit that comprises
the TemplateReviews example. It captures class structure, method descriptions, and inter-unit
interactions at a level sufficient for formal code review and compliance verification. The document
does not restate requirements; it explains how they are realized.

## Scope

This document covers the detailed design of the following software units:

- **Helpers** — subsystem grouping related utility classes
  - **MathHelper** — static utility class providing common arithmetic operations (`MathHelper.cs`)
  - **StringHelper** — static utility class providing common string manipulation operations
    (`StringHelper.cs`)

The following topics are out of scope:

- Build pipeline configuration
- Deployment and packaging

## Software Structure

The following tree shows how the software items are organized across the system, subsystem, and
unit levels:

```text
TemplateReviews (System)
└── Helpers (Subsystem)
    ├── MathHelper (Unit)
    └── StringHelper (Unit)
```

Each unit is described in detail in its own design document within the `docs/design/` folder.

## Folder Layout

The source code folder structure mirrors the design documentation, giving reviewers an explicit
navigation aid from design to code:

```text
src/
└── Helpers/
    ├── MathHelper.cs           — arithmetic utility class
    └── StringHelper.cs         — string manipulation utility class

docs/design/
├── introduction.md         — this document; design overview and scope
├── example-system.md       — system-level interactions between subsystems
├── helpers.md              — Helpers subsystem design
├── math-helper.md          — detailed design for MathHelper
└── string-helper.md        — detailed design for StringHelper

test/
└── Helpers/
    ├── MathHelperTests.cs      — tests for MathHelper
    └── StringHelperTests.cs    — tests for StringHelper
```
