# ContinuousCompliance

[![License](https://img.shields.io/github/license/demaconsulting/ContinuousCompliance?style=plastic)](LICENSE)

Documentation of the DEMA Consulting approach to Continuous Compliance for use across its projects.

## Overview

Continuous Compliance is the practice of continuously verifying that a software project meets its quality,
security, and documentation requirements throughout the development lifecycle. Rather than treating compliance
as a one-time activity performed at release, each CI/CD pipeline run enforces compliance gates and generates
up-to-date evidence.

The DEMA Consulting approach encompasses:

- [Linting](#linting) - Enforcing consistent code and document style
- [Tool Version Capture](#tool-version-capture) - Recording the tools used in each build
- [Static Analysis](#static-analysis) - Detecting code quality and security issues
- [Requirements Enforcement](#requirements-enforcement) - Ensuring all requirements are tested
- [Self-Validation](#self-validation) - Verifying DemaConsulting tools function correctly
- [Build Notes Generation](#build-notes-generation) - Generating release change documentation
- [PDF Document Generation](#pdf-document-generation) - Publishing polished release documents

Every release publishes:

- Build information and change notes
- Requirements document
- Trace matrix (requirements to tests)
- Code quality report
- User guide

## Linting

All DEMA Consulting projects use a combination of linters to maintain consistent quality across different file
types:

| Linter | Purpose |
| :----- | :------ |
| [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2) | Markdown style and formatting |
| [cspell](https://github.com/streetsidesoftware/cspell) | Spell-checking across all text files |
| [yamllint](https://github.com/adrienverge/yamllint) | YAML structure and formatting |

These linters are run as the first step in every CI/CD pipeline, ensuring that documentation and configuration
issues are caught immediately. Linting failures block subsequent pipeline steps.

## Tool Version Capture

Understanding exactly which tools were used to produce a build is critical for reproducibility and auditability.
[DemaConsulting.VersionMark](https://github.com/demaconsulting/VersionMark) captures tool version information
from each CI/CD job and publishes a consolidated report.

**How it works:**

1. Each CI/CD job runs `versionmark --capture --job-id <job-id>` to record the versions of configured tools
   (compilers, runtimes, package managers, etc.) into a JSON file.
2. After all jobs complete, `versionmark --publish --report versions.md` consolidates the per-job JSON files
   and generates a markdown versions report, highlighting any version discrepancies across jobs.

The resulting versions document is included in every release, providing a precise record of the build
environment.

## Static Analysis

Static analysis detects code quality and security issues before they reach production. DEMA Consulting projects
use two complementary analysis approaches:

### SonarQube / SonarCloud

[DemaConsulting.SonarMark](https://github.com/demaconsulting/SonarMark) generates markdown reports from
SonarQube or SonarCloud analysis results. It fetches quality gate status, issues, and security hot-spots
directly from the SonarQube/SonarCloud API.

Usage in CI/CD:

```bash
sonarmark --server https://sonarcloud.io \
  --project-key my-org_my-project \
  --token $SONAR_TOKEN \
  --report quality-report.md \
  --enforce
```

The `--enforce` flag causes the pipeline to fail if the quality gate is not passed.

### CodeQL

[DemaConsulting.SarifMark](https://github.com/demaconsulting/SarifMark) processes SARIF (Static Analysis
Results Interchange Format) files produced by CodeQL and other static analysis tools, converting them into
human-readable markdown reports.

Usage in CI/CD:

```bash
sarifmark --sarif analysis.sarif \
  --report codeql-report.md \
  --enforce
```

The `--enforce` flag causes the pipeline to fail if any issues are found.

The code quality report included in every release combines the SonarMark and SarifMark output.

## Requirements Enforcement

[DemaConsulting.ReqStream](https://github.com/demaconsulting/ReqStream) manages requirements written in YAML
files and enforces that every requirement is covered by passing tests.

**How it works:**

1. Requirements are defined in YAML files with unique IDs, titles, justifications, and test mappings.
2. Test results (TRX or JUnit format) from the CI/CD pipeline are collected.
3. ReqStream validates that all requirements have at least one passing test and generates documentation.

Usage in CI/CD:

```bash
reqstream \
  --requirements "docs/**/*.yaml" \
  --tests "test-results/**/*.trx" \
  --report requirements.md \
  --matrix trace-matrix.md \
  --justifications justifications.md \
  --enforce
```

The `--enforce` flag fails the pipeline if any requirement is not covered by a passing test.

Every release includes:

- **Requirements document** - The full list of requirements with titles and justifications
- **Trace matrix** - A mapping of requirements to their covering tests, showing coverage status

## Self-Validation

Each DemaConsulting tool includes a built-in `--validate` command that runs self-validation tests without
requiring external services or repositories. This serves two purposes:

1. **Verification** - Confirms the installed tool version functions correctly in the target environment.
2. **Test Evidence** - Produces TRX or JUnit test result files that ReqStream can use as test coverage
   evidence for the tool's own requirements.

The self-validation step is included in each tool's CI/CD pipeline and the resulting test results are fed
into the requirements enforcement step, enabling the tools to validate themselves using the same compliance
infrastructure they provide to other projects.

| Tool | Self-Validation Command |
| :--- | :---------------------- |
| [VersionMark](https://github.com/demaconsulting/VersionMark) | `versionmark --validate --results results.trx` |
| [SonarMark](https://github.com/demaconsulting/SonarMark) | `sonarmark --validate --results results.trx` |
| [SarifMark](https://github.com/demaconsulting/SarifMark) | `sarifmark --validate --results results.trx` |
| [ReqStream](https://github.com/demaconsulting/ReqStream) | `reqstream --validate --results results.trx` |
| [BuildMark](https://github.com/demaconsulting/BuildMark) | `buildmark --validate --results results.trx` |

## Build Notes Generation

[DemaConsulting.BuildMark](https://github.com/demaconsulting/BuildMark) generates markdown build notes from
Git repository history and GitHub issues. It analyses commits, pull requests, and issues between the previous
and current release tags to produce a human-readable change summary.

Usage in CI/CD:

```bash
buildmark \
  --build-version v1.2.3 \
  --report build-notes.md \
  --include-known-issues
```

The generated build notes document is included in every release and covers:

- Version information (current version, baseline, commit)
- Changes and new features
- Bugs fixed
- Known issues (optional)
- Link to the complete changelog

## PDF Document Generation

Release documentation is published as polished PDF documents using a two-step process:

1. **[Pandoc](https://pandoc.org/)** converts the generated markdown documents into an intermediate HTML
   format, combining multiple markdown files (build notes, requirements, trace matrix, quality report,
   user guide) into a single document.
2. **[Weasyprint](https://weasyprint.org/)** renders the HTML into a PDF, applying a consistent visual style
   across all DEMA Consulting release documents.

This pipeline produces professional-quality PDFs from plain markdown sources, ensuring the released
documentation is both machine-generated (and therefore always up-to-date) and visually consistent.

## Release Artifacts

Every release produced by a DEMA Consulting project that follows this approach publishes the following
artifacts:

| Artifact | Tool(s) | Description |
| :------- | :------ | :---------- |
| Build Notes | [BuildMark](https://github.com/demaconsulting/BuildMark) | Changes, bug fixes, and version information for this release |
| Requirements | [ReqStream](https://github.com/demaconsulting/ReqStream) | Full list of requirements with justifications |
| Trace Matrix | [ReqStream](https://github.com/demaconsulting/ReqStream) | Requirements-to-tests coverage matrix |
| Code Quality Report | [SonarMark](https://github.com/demaconsulting/SonarMark), [SarifMark](https://github.com/demaconsulting/SarifMark) | SonarQube/SonarCloud and CodeQL analysis results |
| User Guide | Project-specific | Comprehensive usage documentation |

All artifacts are generated automatically by the CI/CD pipeline and attached to the GitHub Release.

## License

Copyright (c) DEMA Consulting. Licensed under the [MIT License](LICENSE).
