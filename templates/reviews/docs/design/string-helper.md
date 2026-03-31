# StringHelper Design

## Overview

The `StringHelper` class is a static utility class that provides common string
manipulation operations. It is a software unit in the sense of IEC 62304 — the
smallest independently testable component in the codebase.

## Design Decisions

### Static Class

`StringHelper` is designed as a static class because all of its operations are
pure functions: they depend only on their input parameters and produce no side
effects. Static methods avoid unnecessary object instantiation and make call
sites concise.

### Delegation to Standard Library

Where possible, the methods delegate to well-tested .NET standard library
functions (e.g. `string.ToUpper()`, `string.ToCharArray()`) to minimise custom
logic and reduce the risk of defects.

## Method Descriptions

### `Reverse(string value)`

Returns the characters of `value` in reverse order by converting the string to
a character array, reversing it with LINQ, and constructing a new string.
Satisfies requirement `TemplateReviews-StringHelper-Reverse`.

### `ToUpper(string value)`

Returns `value` converted to upper case using the current culture.
Satisfies requirement `TemplateReviews-StringHelper-ToUpper`.
