# System Design

## Overview

This document describes how the MathHelper and StringHelper software units work together as an
integrated example system. Where the unit design documents (`math-helper-design.md` and
`string-helper-design.md`) each describe one component in isolation, this document focuses on
the system-level structure and any cross-cutting concerns.

In a real project this document would describe end-to-end data flows, coordination points between
units, and integrated scenarios that the units collectively enable.

## System Structure

The TemplateReviews example is a minimal system comprising two independent, stateless utility
classes. Both classes are designed as static classes whose methods are pure functions with no
shared state:

| Unit | Purpose | Dependencies |
| :--- | :------ | :----------- |
| `MathHelper` | Arithmetic operations on integers | None |
| `StringHelper` | String manipulation operations | Standard library only |

## Independent Operation

The two units operate entirely independently — neither calls the other, and they share no data or
state. This design keeps each unit focused and easy to test in isolation.

## Interactions Between Units

| Calling Unit | Called Unit | Call Site | Purpose |
| :----------- | :---------- | :-------- | :------ |
| *(none)* | `MathHelper` | Consumer code | Consumers call `MathHelper` directly |
| *(none)* | `StringHelper` | Consumer code | Consumers call `StringHelper` directly |

In a real project this table would document inter-unit calls, the data passed between units, and
the sequence of operations across an integrated processing pipeline.
