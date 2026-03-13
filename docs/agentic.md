# AI Coding Agents

AI coding agents are most effective when they understand the standards they are being held to before they
write a single line of code. Without that context, an agent implementing a feature must discover
compliance requirements through repeated CI failure cycles — adding a requirement entry after a
ReqStream enforcement failure, fixing linting errors after a markdownlint failure, adjusting code style
after a formatter check failure.

Continuous Compliance projects short-circuit this cycle by providing agents with machine-readable,
authoritative project standards up front. When an agent consults these files at the start of a task, it
can produce compliant code on the first attempt.

## Agent Guidance Files

DEMA Consulting projects use two layers of agent guidance:

### AGENTS.md — Root Quick Reference

`AGENTS.md` at the repository root is the primary entry point for any agent working on the project. It
is a compact quick-reference card covering everything an agent needs to know to work effectively:

- **Available specialized agents** — roles defined for the project and when to invoke each
- **Tech stack** — languages, frameworks, runtimes, and package managers in use
- **Key files** — location of `requirements.yaml`, linting configs, and `.editorconfig`
- **Requirements rules** — all requirements must be linked to tests; enforced in CI
- **Test source filters** — platform- and runtime-specific test evidence requirements
- **Test naming conventions** — patterns that make tests linkable to requirements
- **Code style** — XML documentation, error types, namespace style, string formatting
- **Build and test commands** — how to build, test, run self-validation, and lint locally
- **Documentation map** — where user guides, requirements, and trace matrices live

**Example `AGENTS.md` structure:**

```markdown
# Agent Quick Reference

## Available Specialized Agents

- **Requirements Agent** - Develops requirements and ensures test coverage linkage
- **Software Developer** - Writes production code and self-validation tests
- **Test Developer** - Creates unit and integration tests
- **Code Quality Agent** - Enforces linting, static analysis, and security standards

## Requirements

- All requirements MUST be linked to tests (enforced via `dotnet reqstream --enforce`)
- When adding features: add requirement + link to test

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
```

### .github/agents/ — Specialized Role Instructions

For projects that use specialized agent roles, each role has its own instruction file in
`.github/agents/`. These files define the role's responsibilities, when to invoke it, what it owns,
and which other agents it defers to.

DEMA Consulting projects define the following specialized roles:

| Agent | File | Responsibilities |
| :---- | :--- | :--------------- |
| Requirements Agent | `requirements-agent.md` | Creates and maintains `requirements.yaml`; determines test coverage strategy |
| Software Developer | `software-developer.md` | Writes production code and self-validation tests in literate style |
| Test Developer | `test-developer.md` | Creates unit and integration tests following the AAA pattern |
| Code Quality Agent | `code-quality-agent.md` | Enforces all quality gates (linting, static analysis, requirements traceability) |
| Technical Writer | `technical-writer.md` | Creates and maintains documentation following regulatory best practices |
| Repo Consistency Agent | `repo-consistency-agent.md` | Ensures downstream repositories remain consistent with template patterns |

Role files use the GitHub Copilot agent front-matter format:

```markdown
---
name: Requirements Agent
description: Develops requirements and ensures appropriate test coverage linkage
---

# Requirements Agent

...
```

## What Helps Agents Most

The following information, when present in `AGENTS.md` or role files, has the highest impact on
agent compliance:

### Requirements Format

Agents that know the `requirements.yaml` schema can add correctly formatted requirements when they
add features, rather than leaving requirements management as a separate pass:

```yaml
sections:
  - title: Functional Requirements
    requirements:
      - id: Tool-Version
        title: The tool shall display version information.
        justification: Users need to verify the installed tool version.
        tests:
          - TemplateTool_VersionDisplay
```

### Test Naming Conventions

When the test naming convention is documented, agents can write tests whose names will automatically
match requirement links in `requirements.yaml`. For example, DEMA Consulting tools use the pattern
`ToolName_FeatureName` for self-validation tests. An agent that knows this will name its test
`MyTool_NewFeature` and link it in requirements as `MyTool_NewFeature` — immediately satisfying the
ReqStream enforcement check.

### Test Source Filters

When requirements need platform-specific or runtime-specific evidence, the source filter syntax must
be documented. An agent that understands that `windows@TestName` restricts evidence to Windows
results will write and link tests correctly, rather than accidentally removing filters that invalidate
compliance evidence.

### Quality Gates

Knowing all the quality gates the CI enforces — build warnings, linting, static analysis, requirements
traceability, test results — allows an agent to validate its own work before triggering a pipeline
run. The Code Quality Agent role captures this checklist in its instruction file, making it reusable
across agent sessions.

### Code Style

Documenting `.editorconfig` conventions in human-readable form (`AGENTS.md`) prevents the most common
class of agent style violations: incorrect namespace declaration style, missing XML documentation,
wrong string formatting. An agent that knows these rules generates code that passes `dotnet format`
without additional correction.

## Agent Report Files

When agents need to communicate intermediate results or hand off work between roles, they write
report files. DEMA Consulting projects use a naming convention that keeps these files out of the
committed codebase:

- **Pattern**: `AGENT_REPORT_<description>.md` (e.g., `AGENT_REPORT_analysis.md`)
- **Purpose**: Temporary inter-agent communication; not intended for long-term storage
- **Exclusions**: Files matching this pattern are excluded from:
  - Git tracking (via `.gitignore`)
  - Markdown linting
  - Spell checking

This prevents agent-generated scratch files from polluting the project history or triggering false
linting failures.

## Continuous Compliance as Agent Context

From an agent's perspective, a Continuous Compliance project is self-documenting: the standards it
enforces are written in the same repository the agent is working in. A fully equipped Continuous
Compliance project provides an agent with:

- **What to build** — `requirements.yaml` defines all requirements
- **How to prove it** — test naming conventions and source filters define the evidence format
- **What style to follow** — `.editorconfig`, `.cspell.json`, `.markdownlint-cli2.jsonc`, `.yamllint.yaml`
- **What gates to pass** — `AGENTS.md` and role files enumerate every CI enforcement step
- **Where to look** — the documentation map points to guides, requirements, and trace matrices

An agent that reads `AGENTS.md` at the start of every session has all of this context available
immediately, without needing to discover it through trial and error.

## ReviewMark and AI-Assisted Reviews

Beyond its role in CI/CD enforcement, ReviewMark's review-set grouping is directly useful for
AI-assisted reviews. When an AI agent is asked to review a feature or subsystem, directing it to
the corresponding review-set in `.reviewmark.yaml` gives it a precise, pre-defined scope that
groups all relevant files together.

Review-sets designed for AI context group requirements, design documentation, source code, and
tests by feature area. An agent that reviews all files in a review-set at once can reason across
the full chain of evidence — from what the code must do (requirements), to how it is structured
(design), to what it actually does (code), to what is verified (tests) — rather than reviewing
any one category in isolation.

This context-aware grouping enables agents to identify:

- **Requirements gaps** — behaviors required but not implemented or not tested
- **Documentation drift** — design documents that no longer reflect the implementation
- **Coverage gaps** — code paths not covered by any test
- **Consistency issues** — discrepancies between stated requirements and actual behavior

See [File Reviews](file-reviews.md#ai-assisted-reviews) for guidance on designing review-sets
that maximize the usefulness of AI-assisted reviews.
