# AI Coding Agents and Continuous Compliance

## The Challenge: Agents Without Constraints

AI coding agents left to their own devices tend to "vibe-code" — implementing what they think
is wanted based on the immediate prompt, without considering the broader system they are
working within. An unconstrained agent rarely asks:

- Does this feature have a documented requirement?
- Are all existing requirements still linked to passing tests?
- Does the new code meet the project's formatting and style rules?
- Does the changed file need a formal review record?

Without this context, the agent will often produce something that works in isolation but
fails the project's compliance gates. The result is a CI failure loop: add a requirement
entry after a ReqStream enforcement failure, fix linting errors after a markdownlint failure,
adjust code style after a formatter check failure — each cycle costing another pipeline run
and more agent turns.

## The Context Problem

The obvious solution — "just give the agent the whole repository" — does not scale. A
typical software project contains hundreds of source files, multiple documentation
directories, configuration files, test suites, and generated artifacts. Loading everything
floods the agent's context window with information irrelevant to the current task, crowding
out the content the agent actually needs to reason well.

What agents need is **targeted, structured context**: enough information to understand the
project's standards and their current task, without drowning in the rest of the codebase.

## How Continuous Compliance Helps

Continuous Compliance projects provide that targeted context through a set of machine-readable
files — each covering one layer of the project — that an agent can load selectively. Together
they build a complete picture of the project from general to specific, but an agent only needs
to load the layers relevant to its task:

+----------------------+-----------------------------------------------+----------------------------------------------+
| Layer                | File(s)                                       | What It Tells an Agent                       |
+======================+===============================================+==============================================+
| **Requirements**     | `requirements.yaml`                           | What the software must do; which tests       |
|                      |                                               | prove it                                     |
+----------------------+-----------------------------------------------+----------------------------------------------+
| **Review coverage**  | `.reviewmark.yaml`                            | Which files need formal review; how they     |
|                      |                                               | are grouped                                  |
+----------------------+-----------------------------------------------+----------------------------------------------+
| **Code quality**     | `.editorconfig`, `.cspell.yaml`,              | How code and documentation must be           |
|                      | `.markdownlint-cli2.yaml`, `.yamllint.yaml`   | formatted                                    |
+----------------------+-----------------------------------------------+----------------------------------------------+
| **Domain standards** | `.github/standards/*.md`                      | Detailed language, testing, requirements,    |
|                      |                                               | and documentation standards for specific     |
|                      |                                               | domains; loaded selectively by agents        |
+----------------------+-----------------------------------------------+----------------------------------------------+
| **Build and test**   | `AGENTS.md`                                   | How to build, test, and lint locally;        |
|                      |                                               | where everything lives; which agent to       |
|                      |                                               | delegate to for specific tasks               |
+----------------------+-----------------------------------------------+----------------------------------------------+

An agent implementing a new feature needs the requirements layer and the build layer. An agent
performing a code review needs the review-coverage layer and the requirements layer. An agent
fixing a documentation spelling error needs only the code-quality layer. None of them needs
to read the whole repository.

This is the core benefit of Continuous Compliance for agentic development: **the project
documents its own standards in a form that machines can read, so agents can load exactly what
they need, when they need it.**

## AGENTS.md — The Entry Point

`AGENTS.md` at the repository root is the primary entry point for any agent working on the
project. It is a compact quick-reference card — a map to the project's standards — covering
the essential information an agent needs to orient itself before starting work:

- **Key compliance files** — where to find `requirements.yaml`, `.reviewmark.yaml`, and linting configs
- **Standards application** — which `.github/standards/` files to load for each type of work
- **Delegation guidelines** — which specialized agent to call for different task types
- **Requirements rules** — all requirements must be linked to tests; enforced in CI
- **Test source filters** — platform- and runtime-specific test evidence requirements
- **Test naming conventions** — patterns that make tests linkable to requirements
- **Code style** — formatting rules, documentation conventions, naming patterns
- **Build and test commands** — how to build, test, and lint locally

An agent that reads `AGENTS.md` at the start of every session has an immediate, accurate
picture of the project's structure and standards, without needing to discover them through
trial and error or CI failure.

**Example `AGENTS.md` structure:**

```markdown
# Agent Quick Reference

## Standards Application (ALL Agents Must Follow)

Before performing any work, read the relevant standards from `.github/standards/`:

- **`language.md`** — For code development (naming, style, documentation conventions)
- **`testing.md`** — For test development (patterns, naming, anti-patterns)
- **`reqstream-usage.md`** — For requirements management (traceability, IDs, source filters)
- **`reviewmark-usage.md`** — For file review management (review-sets, patterns, enforcement)

Load only the standards relevant to your task scope.

## Agent Delegation Guidelines

The default agent should handle simple tasks directly.
Delegate to specialized agents for specific scenarios:

- **Simple fixes, small features** → Call the developer agent
- **Formal feature implementation** → Call the implementation agent
- **Formal code reviews** → Call the code-review agent

## Key Compliance Files

- `requirements.yaml` — all project requirements (ALL must be linked to passing tests)
- `.reviewmark.yaml` — files requiring formal review and named review-set groupings
- `.cspell.yaml`, `.markdownlint-cli2.yaml`, `.yamllint.yaml` — linting configuration
- `.editorconfig` — code formatting rules

## Requirements Rules

- ALL requirements MUST be linked to tests (enforced via `dotnet reqstream --enforce`)
- When adding features: add a requirement entry and link to at least one test
- When writing tests: name them so they can be linked in `requirements.yaml`

## Test Source Filters

- `windows@TestName` - proves the test passed on a Windows platform
- `ubuntu@TestName` - proves the test passed on a Linux platform

## Code Style

- XML Docs on ALL members
- File-scoped namespaces only
- Use interpolated strings ($"") for clarity

## Build and Test

dotnet build --configuration Release
dotnet test --configuration Release
./lint.sh   # or lint.bat on Windows
```

## Agent Guidance Files

For larger or more complex projects, a single `AGENTS.md` may not be enough. Projects can
provide additional layers of guidance through role files and standards files:

### Specialized Role Files

Projects that use specialized agent roles place an instruction file for each role in
`.github/agents/`. These files define the role's responsibilities, when to invoke it, what
it owns, and which other agents it defers to. This allows different agents to load only the
guidance relevant to their role, keeping each agent's context focused.

Role files use the `{role}.agent.md` naming convention and the GitHub Copilot agent
front-matter format:

```markdown
---
name: developer
description: >
  General-purpose software development agent that applies appropriate standards
  based on the work being performed.
user-invocable: true
---

# Developer Agent

...
```

### Standards Files

Projects place domain-specific standards in `.github/standards/`. Each file covers one
technical domain — language conventions, testing practices, requirements management,
design documentation, and so on. Unlike the compact quick-reference in `AGENTS.md`, these
files contain the full detail agents need to produce compliant output in complex situations.

`AGENTS.md` lists the standards files available and instructs all agents to read the
relevant ones before starting work. Agents load only the standards applicable to their
task, keeping their context focused.

By placing these files in the repository alongside the code they govern, projects make their
standards self-documenting: an agent working on requirements loads `reqstream-usage.md`; an
agent performing a review loads `reviewmark-usage.md`. No external configuration or
pre-training is required — the project explains itself.

## Agent Report Files

When agents need to communicate intermediate results or hand off work between roles, they
write report files to a dedicated folder. Projects using agentic workflows typically use
a `.agent-logs/` folder that is excluded from source control and linting:

- **Location**: `.agent-logs/[agent-name]-[subject]-[unique-id].md`
- **Purpose**: Records work performed, decisions made, and follow-up items; also used for
  temporary inter-agent communication
- **Exclusions**: The `.agent-logs/` folder is excluded from:
  - Git tracking (via `.gitignore`)
  - Markdown linting
  - Spell checking

This prevents agent-generated log files from polluting the project history or triggering
false linting failures.

## ReviewMark and AI-Assisted Reviews

Beyond its role in CI/CD enforcement, ReviewMark's review-set grouping is directly useful for
AI-assisted reviews. When an AI agent is asked to review a feature or subsystem, directing it
to the corresponding review-set in `.reviewmark.yaml` gives it a precise, pre-defined scope
that groups all relevant files together.

A well-designed review-set contains all the files that belong together conceptually:
requirements documents, design documents, source code, and tests that collectively form a
coherent unit of functionality. An agent that reviews all files in a review-set at once can
reason across the full chain of evidence:

- **Requirements** — what the code must do and why
- **Design documents** — how the code is structured and the rationale behind key decisions
- **Source code** — what the code actually does
- **Tests** — which behaviors are verified and how

This context-aware grouping enables agents to identify:

- **Requirements gaps** — behaviors required but not implemented or not tested
- **Documentation drift** — design documents that no longer reflect the implementation
- **Coverage gaps** — code paths not covered by any test
- **Consistency issues** — discrepancies between stated requirements and actual behavior

Without ReviewMark's explicit groupings, an agent asked to "review the authentication module"
must guess which files are relevant, often missing files or including unrelated ones. With
ReviewMark, the scope is authoritative and machine-readable — the agent loads exactly the
right files, every time.

See [File Reviews](file-reviews.md#ai-assisted-reviews) for guidance on designing review-sets
that maximize the usefulness of AI-assisted reviews.

