# Helpers Subsystem Design

## Overview

The Helpers subsystem provides static utility classes for common operations used throughout
the TemplateReviews example system. It groups the MathHelper and StringHelper units, which
share the common characteristic of being pure-function, stateless utilities with no external
dependencies.

## Subsystem Responsibilities

The Helpers subsystem is responsible for:

- Providing arithmetic operations on integer values (`MathHelper`)
- Providing string manipulation operations (`StringHelper`)

The subsystem satisfies requirements at the subsystem level through the emergent behavior of its
constituent units. Neither unit is aware of the other; the subsystem boundary exists only to
group related utility functionality together for design and review purposes.

## Units in this Subsystem

| Unit | Source File | Purpose |
| :--- | :---------- | :------ |
| `MathHelper` | `src/Helpers/MathHelper.cs` | Common arithmetic operations on integers |
| `StringHelper` | `src/Helpers/StringHelper.cs` | Common string manipulation operations |

Each unit is documented in detail in its own design document.

## Interactions Between Units

| Calling Unit | Called Unit | Purpose |
| :----------- | :---------- | :------ |
| *(none)* | `MathHelper` | Consumer code calls directly |
| *(none)* | `StringHelper` | Consumer code calls directly |

The two units within this subsystem do not call each other. Each unit exposes independent
pure-function operations that consumers invoke directly.
