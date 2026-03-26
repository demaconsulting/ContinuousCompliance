# Adopting Continuous Compliance in Existing Projects

This guide describes a practical, incremental approach for introducing Continuous Compliance into a
project that already has an established codebase, CI/CD pipeline, and release process. The goal is to
add compliance automation progressively without disrupting day-to-day development.

## Guiding Principles

- **One stage at a time** — add each pipeline stage independently; do not attempt to introduce
  linting, requirements enforcement, and file reviews simultaneously
- **Green first** — before enforcing any gate, run it in reporting mode until all existing failures
  are resolved
- **Match the existing process** — Continuous Compliance adds automation around your current
  practices; it does not require a new branching strategy, issue tracker, or development workflow

## Migration Checklist

### Stage 1: Linting

Linting is the lowest-risk starting point. It has no dependency on other pipeline stages and can be
introduced with a single CI/CD job.

- [ ] Copy `lint.sh`, `lint.bat`, `package.json`, `pip-requirements.txt`, and the lint
  configuration files from
  [`templates/lint/`](https://github.com/demaconsulting/ContinuousCompliance/tree/main/templates/lint)
  into your repository root
- [ ] Run `bash ./lint.sh` locally and resolve all linting errors in existing files
- [ ] Add a lint job to your CI/CD pipeline
- [ ] Verify the lint job passes on every open branch

See [Linting](linting.md) for configuration details.

### Stage 2: Tool Version Capture

VersionMark records exactly which tool versions were used in each CI/CD job. Adding it has no
enforcement consequences — it only produces a report.

- [ ] Add `.versionmark.yaml` to the repository root, listing the tools used in your build jobs
- [ ] Add a VersionMark capture step to each CI/CD job
- [ ] Add a VersionMark publish step to your document generation (or release) job
- [ ] Confirm the versions report is generated and attached to releases

See [Tool Version Capture](tool-versions.md) for configuration details.

### Stage 3: Static Analysis

SonarQube/SonarCloud and CodeQL are typically already present in mature projects. If so, adding
SonarMark and SarifMark only adds reporting — no new analysis is introduced. If not yet configured,
add the analysis jobs to your CI/CD pipeline as part of this stage.

- [ ] If SonarQube/SonarCloud is not already configured, add SonarScanner to your build CI/CD job
  (wrapping the build and test steps); otherwise confirm the existing quality gate passes
- [ ] Add a SonarMark reporting step to your document generation job (no `--enforce` yet)
- [ ] If CodeQL is not already configured, add a dedicated CodeQL analysis CI/CD job; otherwise
  confirm it is producing SARIF output
- [ ] Add a SarifMark reporting step to your document generation job (no `--enforce` yet)
- [ ] Review the generated reports and resolve any existing findings
- [ ] Add `--enforce` to SonarMark and SarifMark once all findings are resolved

See [Static Analysis](static-analysis.md) for configuration details.

### Stage 4: Requirements

Introducing requirements management into an existing project is the most significant migration step.
The recommended approach is to document what already exists, not to redesign the project.

- [ ] Install ReqStream: copy `.config/dotnet-tools.json` from
  [`templates/reqstream/`](https://github.com/demaconsulting/ContinuousCompliance/tree/main/templates/reqstream)
  or add the tool to your existing manifest
- [ ] Create `requirements.yaml` at the repository root
- [ ] Add YAML requirements files under `docs/reqstream/`, one per subsystem or component,
  using the template examples as a starting point
- [ ] Map each requirement to one or more existing tests using the `tests` field
- [ ] Run ReqStream locally **without** `--enforce` and review the trace matrix
- [ ] Work through any uncovered requirements: either write new tests or retire requirements that
  no longer reflect the project's behavior
- [ ] Add ReqStream to your CI/CD document generation job **without** `--enforce`
- [ ] Add `--enforce` once all requirements are covered by passing tests

See [Requirements Enforcement](requirements.md) for format and CI/CD integration details.

### Stage 5: File Reviews

File reviews enforce that every reviewable file has been formally reviewed and that the review is
still current. This stage is most valuable for regulated projects, but the evidence it generates is
useful for any team.

- [ ] Install ReviewMark: add it to `.config/dotnet-tools.json`
- [ ] Create `.reviewmark.yaml` defining which files require review and how they are grouped into
  review-sets; start with `evidence-source: type: none` (no evidence store required yet)
- [ ] Conduct initial reviews for all files matching the `needs-review` patterns and store the
  evidence PDFs in your evidence store
- [ ] Update `evidence-source` in `.reviewmark.yaml` to point to your evidence store (`url` or
  `fileshare`) once it is provisioned
- [ ] Run ReviewMark locally **without** `--enforce` and review the review plan and report
- [ ] Add ReviewMark to your CI/CD document generation job **without** `--enforce`
- [ ] Add `--enforce` once all files are covered by current reviews

See [File Reviews](file-reviews.md) for configuration and evidence storage details.

### Stage 6: PDF Document Generation

PDF generation collects all the documents produced by previous stages and renders them as polished,
archivable PDF/A-3u files. It depends on all upstream stages being in place.

- [ ] Install Pandoc and Weasyprint: add them to `.config/dotnet-tools.json`
- [ ] Install npm dependencies: add `mermaid-filter` as a devDependency in `package.json` and run
  `npm install`
- [ ] Create `definition.yaml` files for each document type
- [ ] Create a shared HTML template and CSS stylesheet
- [ ] Add Pandoc and Weasyprint steps to your CI/CD release job
- [ ] Confirm PDFs are generated and attached to GitHub Releases

See [PDF Document Generation](pdf-generation.md) for the full pipeline.

## Handling Existing Documentation

Most projects accumulate documentation that pre-dates Continuous Compliance. The recommended approach:

1. **Audit** — identify which existing documents should become managed (linted, reviewed, and
   published as PDFs) and which are informal notes that do not need to enter the compliance pipeline
2. **Lint first** — run markdownlint-cli2 and cspell against existing documentation and fix all
   errors before adding the documents to the pipeline
3. **One document at a time** — add each managed document to the PDF generation pipeline
   independently, verify the output, then move to the next

## Handling Existing Tests

ReqStream links requirements to tests by test name. When adopting requirements enforcement in a
project with an existing test suite:

1. **Do not rename tests** that are already passing — changing a test name breaks any existing
   requirements links and may affect other tooling
2. **Add requirements for what tests already verify** — start by documenting what the existing
   tests cover, not by writing new requirements for uncovered areas
3. **Grow coverage incrementally** — once existing tests are linked, identify uncovered functional
   areas and add requirements and tests for them

## Rollback Considerations

Every Continuous Compliance pipeline stage is independently removable. If a stage causes problems,
remove it from the pipeline without affecting other stages. The compliance documents it generated
will remain in your release history.
