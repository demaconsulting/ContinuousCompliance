# Continuous Compliance

[![License](https://img.shields.io/github/license/demaconsulting/ContinuousCompliance?style=plastic)](LICENSE)

The DEMA Consulting approach to Continuous Compliance — automated, evidence-based software quality enforced
on every CI/CD run.

## Why Continuous Compliance?

In many software projects, compliance is treated as a last-mile activity: a checklist ticked before release.
This leads to predictable problems:

- **Last-minute surprises** — audits reveal missing test coverage or stale documentation days before a deadline
- **Inconsistency** — quality checks applied differently (or not at all) across builds and releases
- **Documentation drift** — requirements, trace matrices, and quality reports written once and never updated
- **Manual effort** — evidence gathering is slow, error-prone, and impossible to scale

The root cause is timing. When compliance work is deferred to release, every problem costs far more to fix
than if it had been caught earlier.

## What is Continuous Compliance?

Continuous Compliance integrates quality enforcement into every CI/CD pipeline run. Rather than checking
compliance once at the end, every commit automatically:

- ✅ **Enforces** documentation and style standards (linting)
- ✅ **Verifies** all requirements are covered by passing tests
- ✅ **Checks** code quality gates (SonarQube/SonarCloud and CodeQL)
- ✅ **Records** the exact tool versions used to build the software
- ✅ **Confirms** file reviews are current and every reviewable file is covered
- ✅ **Generates** a complete, up-to-date audit trail with every build

Problems are surfaced at the commit that introduced them — not weeks later. Every release ships with
**automatically generated, verified documentation** proving the software meets its requirements.

## Benefits

### For All Development Teams

- **Catch problems early** — issues are found at the commit that introduced them, not at release time
- **Always-current docs** — build notes, quality reports, requirements, and trace matrices are regenerated
  on every build so they are never stale
- **Faster audits** — all evidence is pre-generated and attached to every release; nothing to chase down
- **Transparent quality** — requirements coverage and code quality status are visible to the whole team
  at all times
- **Lower overhead** — automation eliminates the manual evidence-gathering sprint before each release

### Additional Benefits for Regulated Industries

Regulated domains (medical devices, automotive, avionics, industrial control) require documented proof that
software meets its requirements before it can be certified. Continuous Compliance directly addresses these
needs:

- **Traceability** — every requirement is linked to tests, and every test result is archived with the release
- **Justifications** — the rationale behind each requirement is captured alongside the requirement itself
- **Repeatable process** — the same pipeline enforces the same gates on every build, eliminating human
  variability
- **Standards alignment** — the requirements → tests → evidence model maps naturally to IEC 62443,
  DO-178C, ISO 26262, and similar standards

## Repository Model

Continuous Compliance is designed around the **polyrepo** model — one repository per deliverable
package. Each repository is treated as a self-contained machine that produces a single package and
its complete set of compliance evidence (build notes, code quality report, requirements trace matrix,
review records, and PDF release documentation).

This model works well because:

- Every repository has a clear scope — one package, one set of requirements, one release
- Each release is independently auditable — all evidence is generated from the same source and
  version-tagged together
- Teams can adopt the approach incrementally — one repository at a time, without changing others

**Monorepo note:** Continuous Compliance does not map as naturally to monolithic repositories
(monorepos) that build multiple packages from a single codebase. In a monorepo, requirements,
reviews, and release artifacts span many components, making it harder to produce per-package
compliance evidence with a single pipeline. Projects that must use a monorepo can still apply
individual pipeline stages (linting, static analysis, requirements enforcement) but will need to
design custom artifact scoping to produce meaningful per-package release documents.

## The DEMA Consulting Approach

DEMA Consulting implements Continuous Compliance across its projects using a standardized CI/CD pipeline
made up of composable, open-source-friendly tools.

### Pipeline Overview

Each CI/CD run progresses through the following stages:

1. **Lint** — markdownlint-cli2 · cspell · yamllint · yamlfix
2. **Build** — dotnet build/test + SonarScanner
3. **Analyze** — CodeQL (produces SARIF output)
4. **Validate** — Tool self-validation (produces TRX/JUnit output)
5. **Document** — BuildMark · VersionMark · SonarMark · SarifMark · ReqStream (enforces requirements coverage) · ReviewMark (enforces file-review currency)
6. **Publish** — Pandoc (Markdown→HTML) → Weasyprint (HTML→PDF) → FileAssert (validates output documents)

### Tools

| Category | Tool | Purpose |
| :------- | :--- | :------ |
| Linting | [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2) | Markdown style and formatting |
| Linting | [cspell](https://github.com/streetsidesoftware/cspell) | Spell-checking across all text files |
| Linting | [yamllint](https://github.com/adrienverge/yamllint) | YAML structure and formatting |
| Linting | [yamlfix](https://github.com/lyz-code/yamlfix) | YAML fixer |
| Version Capture | [VersionMark](https://github.com/demaconsulting/VersionMark) | Records tool versions for each CI/CD job |
| Static Analysis | [SonarMark](https://github.com/demaconsulting/SonarMark) | SonarQube/SonarCloud quality gate reporting |
| Static Analysis | [SarifMark](https://github.com/demaconsulting/SarifMark) | CodeQL/SARIF analysis reporting |
| Requirements | [ReqStream](https://github.com/demaconsulting/ReqStream) | Requirements management and traceability enforcement |
| File Reviews | [ReviewMark](https://github.com/demaconsulting/ReviewMark) | File-review evidence management and currency enforcement |
| Build Notes | [BuildMark](https://github.com/demaconsulting/BuildMark) | Release change notes from Git history |
| PDF Generation | [Pandoc](https://pandoc.org/) | Converts Markdown documents to HTML |
| PDF Generation | [Weasyprint](https://weasyprint.org/) | Renders HTML to polished PDF documents |
| File Assertions | [FileAssert](https://github.com/demaconsulting/FileAssert) | Validates pipeline outputs — file existence, size, text content, PDF metadata, XML, YAML, JSON, and HTML structure |

## Release Artifacts

Every release automatically publishes the following PDF documents:

| Artifact | Contents |
| :------- | :------- |
| **Build Notes** | Changes, bug fixes, tool versions, and build environment for this release |
| **User Guide** | Comprehensive usage documentation |
| **Code Quality** | SonarQube/SonarCloud and CodeQL analysis results |
| **Requirements** | Full requirements list with IDs, titles, and justifications |
| **Requirements Justifications** | Rationale behind each requirement |
| **Trace Matrix** | Requirements-to-tests coverage evidence |
| **Review Plan** | All files requiring review and the review-set covering each file |
| **Review Report** | Currency status of each review-set (Current, Stale, or Missing) |

All artifacts are generated automatically by the CI/CD pipeline and attached to the GitHub Release.

## AI Coding Agents

Continuous Compliance is particularly well suited to AI-assisted development. When coding agents know
what standards they will be held to, they can produce compliant code on the first attempt — instead of
iterating through multiple CI failures.

Projects using the DEMA Consulting approach provide agents with machine-readable, authoritative standards
through three complementary mechanisms:

- **`AGENTS.md`** at the repository root — a quick-reference card covering the tech stack, requirements
  format, test naming conventions, linting configs, code style rules, how to build and test, and
  delegation guidelines that route tasks to the appropriate specialized agent
- **`.github/standards/*.md`** — domain-specific standards files covering language conventions, testing
  practices, requirements management, design documentation, and other detailed guidance that agents load
  selectively based on their task scope
- **`.github/agents/*.agent.md`** — role-specific instruction files for specialized agents
  (developer, code-review, implementation, quality)

With this context, an agent adding a feature knows from the outset to: add a requirement entry to
`requirements.yaml`, write a test named to match it, follow the coding style in `.editorconfig`, and
confirm the pipeline gates it will need to pass. The result is code that is compliant with project
standards from the start.

ReviewMark review-sets provide a further advantage for AI-assisted reviews. When review-sets are
designed to group related requirements, design documentation, source code, and tests by feature area,
an AI agent can review the complete chain of evidence in one context — seeing what the code must do,
how it is structured, what it actually does, and what is verified — rather than reviewing files in
isolation. This enables more constructive, context-aware review recommendations.

See [AI Coding Agents](docs/agentic.md) for the full documentation on structuring agent guidance files.

## Reference Implementations

DEMA Consulting maintains template projects that demonstrate the full Continuous Compliance pipeline in
practice. These templates are the recommended starting point for new projects:

| Template | Description |
| :------- | :---------- |
| [TemplateDotNetTool](https://github.com/demaconsulting/TemplateDotNetTool) | Full reference implementation for .NET command-line tools |
| [TemplateDotNetLibrary](https://github.com/demaconsulting/TemplateDotNetLibrary) | Full reference implementation for .NET libraries |

## Learn More

Detailed documentation for each part of the pipeline:

- [Linting](docs/linting.md) — markdownlint-cli2, cspell, yamllint, and yamlfix configuration
- [Tool Version Capture](docs/tool-versions.md) — VersionMark setup and usage
- [Static Analysis](docs/static-analysis.md) — SonarMark and SarifMark integration
- [Requirements Enforcement](docs/requirements.md) — ReqStream YAML format and CI/CD integration
- [Design Documentation](docs/design.md) — role of design docs in file reviews and how to structure them
- [File Reviews](docs/file-reviews.md) — ReviewMark configuration, evidence storage, and document signing
- [Self-Validation](docs/self-validation.md) — Tool self-validation as test evidence
- [Build Notes Generation](docs/build-notes.md) — BuildMark configuration and output
- [PDF Document Generation](docs/pdf-generation.md) — Pandoc and Weasyprint pipeline
- [File Assertions](docs/file-assertions.md) — FileAssert configuration, acceptance criteria, OTS evidence, and PDF metadata validation
- [AI Coding Agents](docs/agentic.md) — Structuring agent guidance files for Continuous Compliance
- [Environment Setup](docs/environment-setup.md) — Setting up a local development environment
- [Adopting Continuous Compliance](docs/migration.md) — Incremental migration guide for existing projects
- [Troubleshooting](docs/troubleshooting.md) — Common issues and solutions

## License

Copyright (c) DEMA Consulting. Licensed under the [MIT License](LICENSE).
