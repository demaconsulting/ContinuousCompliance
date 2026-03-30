# System Design

## Overview

This document describes how the TemplateReviews software items work together as an integrated
system. Where the subsystem design document (`helpers.md`) and the unit design documents
(`math-helper-design.md` and `string-helper-design.md`) each describe one component in
isolation, this document focuses on the system-level structure and any cross-cutting concerns.

In a real project this document would describe end-to-end data flows, coordination points between
subsystems, and integrated scenarios that the subsystems collectively enable.

## System Structure

The TemplateReviews example is a minimal system comprising one subsystem that groups two
independent, stateless utility units:

| Item | Type | Purpose |
| :--- | :--- | :------ |
| `Helpers` | Subsystem | Groups utility classes for common operations |
| `MathHelper` | Unit (in Helpers) | Arithmetic operations on integers |
| `StringHelper` | Unit (in Helpers) | String manipulation operations |

## Helpers Subsystem

The Helpers subsystem contains MathHelper and StringHelper. Both units are designed as static
classes whose methods are pure functions with no shared state. The subsystem satisfies
requirements through the emergent behavior of its units; neither unit depends on the other.

See [`helpers.md`](helpers.md) for the detailed subsystem design.

## Interactions Between Subsystems

| Calling Item | Called Item | Call Site | Purpose |
| :----------- | :---------- | :-------- | :------ |
| *(none)* | `Helpers` | Consumer code | Consumers call Helpers units directly |

In a real project this table would document inter-subsystem calls, the data passed between
subsystems, and the sequence of operations across an integrated processing pipeline.
