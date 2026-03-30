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

- **MathHelper** — static utility class providing common arithmetic operations (`MathHelper.cs`)
- **StringHelper** — static utility class providing common string manipulation operations
  (`StringHelper.cs`)

The following topics are out of scope:

- Build pipeline configuration
- Deployment and packaging

## Software Structure

The following tree shows how the software items are organized across the system and unit levels:

```text
TemplateReviews (System)
├── MathHelper (Unit)
└── StringHelper (Unit)
```

Each unit is described in detail in its own design document within the `docs/design/` folder.

## Folder Layout

The source code folder structure mirrors the design documentation, giving reviewers an explicit
navigation aid from design to code:

```text
src/
├── MathHelper.cs           — arithmetic utility class
└── StringHelper.cs         — string manipulation utility class

docs/design/
├── introduction.md         — this document; design overview and scope
├── example-system.md       — system-level interactions between units
├── math-helper-design.md   — detailed design for MathHelper
└── string-helper-design.md — detailed design for StringHelper
```

The test project mirrors the same layout under `test/`.
