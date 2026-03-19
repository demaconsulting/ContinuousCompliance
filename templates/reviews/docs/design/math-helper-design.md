# MathHelper Design

## Overview

The `MathHelper` class is a static utility class that provides common arithmetic
operations. It is a software unit in the sense of IEC 62304 — the smallest
independently testable component in the codebase.

## Design Decisions

### Static Class

`MathHelper` is designed as a static class because all of its operations are
pure functions: they depend only on their input parameters and produce no side
effects. Static methods avoid unnecessary object instantiation and make call
sites concise.

### Integer Arithmetic

The methods operate on `int` parameters to keep the implementation simple and
to avoid floating-point precision issues. Projects that require floating-point
arithmetic should add overloads or a separate helper class.

## Method Descriptions

### `Add(int a, int b)`

Returns `a + b`. Satisfies requirement `TemplateReviews-MathHelper-Add`.

### `Multiply(int a, int b)`

Returns `a * b`. Satisfies requirement `TemplateReviews-MathHelper-Multiply`.
