# File Reviews

In regulated environments, certain files — source code modules, configuration files, design documents
— must be formally reviewed before a release can be approved. Traditionally, tracking which files have
been reviewed, whether a review is still current after a file changes, and whether any files have been
missed is a manual, error-prone process.

[DemaConsulting.ReviewMark](https://github.com/demaconsulting/ReviewMark) automates this process by
maintaining cryptographic fingerprints of reviewed files and querying an evidence store to verify that
every file requiring review is covered by a current, valid review.

## Template Files

The [`templates/reviews`](https://github.com/demaconsulting/ContinuousCompliance/tree/main/templates/reviews)
folder provides a ready-to-use example showing how a complete ReviewMark setup should be structured:

- [`.config/dotnet-tools.json`](https://github.com/demaconsulting/ContinuousCompliance/blob/main/templates/reviews/.config/dotnet-tools.json) — registers both `dotnet reviewmark` and `dotnet reqstream` via .NET local tool manifest
- [`requirements.yaml`](https://github.com/demaconsulting/ContinuousCompliance/blob/main/templates/reviews/requirements.yaml) — root requirements file that includes all files from `docs/reqstream/`
- [`docs/reqstream/math-helper-requirements.yaml`](https://github.com/demaconsulting/ContinuousCompliance/blob/main/templates/reviews/docs/reqstream/math-helper-requirements.yaml) — software unit requirements for `MathHelper`
- [`docs/reqstream/string-helper-requirements.yaml`](https://github.com/demaconsulting/ContinuousCompliance/blob/main/templates/reviews/docs/reqstream/string-helper-requirements.yaml) — software unit requirements for `StringHelper`
- [`docs/design/math-helper-design.md`](https://github.com/demaconsulting/ContinuousCompliance/blob/main/templates/reviews/docs/design/math-helper-design.md) — design document for `MathHelper`
- [`docs/design/string-helper-design.md`](https://github.com/demaconsulting/ContinuousCompliance/blob/main/templates/reviews/docs/design/string-helper-design.md) — design document for `StringHelper`
- [`src/MathHelper.cs`](https://github.com/demaconsulting/ContinuousCompliance/blob/main/templates/reviews/src/MathHelper.cs) — source for the `MathHelper` software unit
- [`src/StringHelper.cs`](https://github.com/demaconsulting/ContinuousCompliance/blob/main/templates/reviews/src/StringHelper.cs) — source for the `StringHelper` software unit
- [`test/MathHelperTests.cs`](https://github.com/demaconsulting/ContinuousCompliance/blob/main/templates/reviews/test/MathHelperTests.cs) — MSTest V4 tests for `MathHelper`
- [`test/StringHelperTests.cs`](https://github.com/demaconsulting/ContinuousCompliance/blob/main/templates/reviews/test/StringHelperTests.cs) — MSTest V4 tests for `StringHelper`
- [`.reviewmark.yaml`](https://github.com/demaconsulting/ContinuousCompliance/blob/main/templates/reviews/.reviewmark.yaml) — two software unit review-sets, each grouping requirements, design, source, and tests

The template demonstrates two software unit review-sets without any subsystem layer, making it easy
to see how requirements, design documents, source files, and tests are grouped together for a focused,
AI-readable review context.

## Role in Continuous Compliance

ReviewMark fills the **file-review evidence** role in the Continuous Compliance pipeline. Every CI/CD
run automatically:

- **Detects stale reviews** — if a reviewed file has changed since the review was conducted, the
  fingerprint no longer matches and the review is flagged as stale
- **Detects missing reviews** — files matching the `needs-review` patterns that are not covered by any
  review-set are flagged as uncovered
- **Enforces coverage** — the `--enforce` flag causes the pipeline to fail if any review is stale,
  missing, or failed

Two documents are produced on every build:

| Document | Purpose |
| :------- | :------ |
| **Review Plan** | Proves every file requiring review is covered by at least one named review-set |
| **Review Report** | Proves each review-set is current — the review evidence matches the current file fingerprint |

These documents are published as PDF/A-3u release artifacts alongside the requirements trace matrix
and code quality report, giving auditors a complete, automatically maintained evidence package on
every release.

## Review Definition

Reviews are configured in a `.reviewmark.yaml` file at the repository root. This file defines which
files require review and how to group them into named review-sets.

```yaml
# .reviewmark.yaml

# Patterns identifying all files that require review.
# Processed in order; prefix a pattern with '!' to exclude.
needs-review:
  - "**/*.cs"
  - "**/*.yaml"
  - "!**/obj/**"           # exclude build output
  - "!src/Generated/**"   # exclude auto-generated files

# Source of review evidence - see ReviewMark user guide.
evidence-source:
  type: none

reviews:
  - id: Core-Logic
    title: Review of core business logic
    paths:
      - "src/Core/**/*.cs"
      - "src/Core/**/*.yaml"
      - "!src/Core/Generated/**"
  - id: Security-Layer
    title: Review of authentication and authorization
    paths:
      - "src/Auth/**/*.cs"
```

### Key Fields

| Field | Description |
| :---- | :---------- |
| `needs-review` | Glob patterns identifying all files that require review coverage |
| `evidence-source` | Source of review evidence (`none`, `url`, or `fileshare`) |
| `evidence-source.credentials` | Optional credentials for authenticated URL sources (see below) |
| `reviews[].id` | Unique identifier for this review-set |
| `reviews[].title` | Human-readable title for the review-set |
| `reviews[].paths` | Glob patterns identifying the files covered by this review-set |

#### Credentials for Authenticated URL Sources

For authenticated URL evidence sources, supply credentials through environment variables so that secrets
are never stored in the definition file or source control:

```yaml
evidence-source:
  type: url
  location: https://reviews.example.com/evidence/index.json
  credentials:
    username-env: REVIEWMARK_USER   # name of the environment variable holding the username
    password-env: REVIEWMARK_TOKEN  # name of the environment variable holding the password
```

In a CI/CD pipeline, map repository secrets to those environment variables:

```yaml
- name: Generate Review Documents
  env:
    REVIEWMARK_USER: ${{ secrets.REVIEW_USER }}
    REVIEWMARK_TOKEN: ${{ secrets.REVIEW_TOKEN }}
  run: >
    dotnet reviewmark
    --definition .reviewmark.yaml
    --plan docs/reviewplan/review-plan.md
    --report docs/reviewreport/review-report.md
    --enforce
```

## Document Folder Structure

Compliant projects **must** have the following two folders committed to source control. Each folder
produces one PDF release artifact and contains a hand-authored `introduction.md` and a Pandoc
`definition.yaml`, following the same convention used by every other pipeline document type:

| Folder | PDF Produced | Hand-authored files |
| :----- | :----------- | :------------------ |
| `docs/reviewplan/` | Review Plan PDF | `introduction.md`, `definition.yaml` |
| `docs/reviewreport/` | Review Report PDF | `introduction.md`, `definition.yaml` |

The generated markdown files (`review-plan.md`, `review-report.md`) are written by ReviewMark on
each CI/CD run and must **not** be committed — they are always regenerated from the current state of
the repository.

```
docs/
  reviewplan/
    introduction.md       # hand-authored introduction for the Review Plan PDF
    definition.yaml       # Pandoc definition for the Review Plan document
    review-plan.md        # generated by ReviewMark --plan (not committed)
  reviewreport/
    introduction.md       # hand-authored introduction for the Review Report PDF
    definition.yaml       # Pandoc definition for the Review Report document
    review-report.md      # generated by ReviewMark --report (not committed)
```

### Pandoc definition.yaml examples

```yaml
# docs/reviewplan/definition.yaml
input-files:
  - docs/reviewplan/introduction.md
  - docs/reviewplan/review-plan.md
template: docs/template/template.html
css: docs/template/template.css
standalone: true
self-contained: true
metadata:
  title: "Review Plan"
  author: "DEMA Consulting"
```

```yaml
# docs/reviewreport/definition.yaml
input-files:
  - docs/reviewreport/introduction.md
  - docs/reviewreport/review-report.md
template: docs/template/template.html
css: docs/template/template.css
standalone: true
self-contained: true
metadata:
  title: "Review Report"
  author: "DEMA Consulting"
```

## CI/CD Integration

ReviewMark runs in the document generation job after all source files are in their final state:

```bash
dotnet reviewmark \
  --definition .reviewmark.yaml \
  --plan docs/reviewplan/review-plan.md \
  --plan-depth 1 \
  --report docs/reviewreport/review-report.md \
  --report-depth 1 \
  --enforce
```

The `--enforce` flag causes the pipeline to fail with a non-zero exit code if any review-set is stale,
missing, or if any file is uncovered. Review documents are always generated before enforcement fails,
so the review plan is available to diagnose coverage gaps.

```yaml
# GitHub Actions steps
- name: Generate Review Documents
  run: >
    dotnet reviewmark
    --definition .reviewmark.yaml
    --plan docs/reviewplan/review-plan.md
    --plan-depth 1
    --report docs/reviewreport/review-report.md
    --report-depth 1
    --enforce

- name: Generate Review Plan HTML
  run: >
    dotnet pandoc
    --defaults docs/reviewplan/definition.yaml
    --metadata version="${{ inputs.version }}"
    --metadata date="$(date +'%Y-%m-%d')"
    --output docs/reviewplan/review-plan.html

- name: Generate Review Plan PDF
  run: >
    dotnet weasyprint
    --pdf-variant pdf/a-3u
    docs/reviewplan/review-plan.html
    "docs/MyProject Review Plan.pdf"

- name: Generate Review Report HTML
  run: >
    dotnet pandoc
    --defaults docs/reviewreport/definition.yaml
    --metadata version="${{ inputs.version }}"
    --metadata date="$(date +'%Y-%m-%d')"
    --output docs/reviewreport/review-report.html

- name: Generate Review Report PDF
  run: >
    dotnet weasyprint
    --pdf-variant pdf/a-3u
    docs/reviewreport/review-report.html
    "docs/MyProject Review Report.pdf"
```

The resulting PDF files are uploaded as pipeline artifacts and attached to the GitHub Release.

## Re-indexing Evidence

When new review evidence PDFs are produced, the evidence store index must be updated. ReviewMark
provides a `--index` command that scans PDF files and writes an up-to-date `index.json`:

```bash
dotnet reviewmark --index "evidence/**/*.pdf"
```

The `index.json` is committed to (or hosted by) the evidence store so that subsequent pipeline runs
can query it.

## PDF Document Storage

Review evidence PDFs need to be stored somewhere accessible to the CI/CD pipeline. The choice of
storage location depends on the team's infrastructure and compliance requirements.

### Recommended Storage Options

| Option | Description | Suitable For |
| :----- | :---------- | :----------- |
| **GitHub repository** | Store evidence PDFs in a dedicated branch or folder in the same repository | Small teams, open-source projects |
| **Separate evidence repository** | A dedicated GitHub/GitLab repository for evidence PDFs | Teams separating code from compliance evidence |
| **Object storage** | AWS S3, Azure Blob Storage, or Google Cloud Storage with a public or token-authenticated URL | Enterprise projects with cloud infrastructure |
| **File share** | A network file share (UNC path) accessible from CI/CD runners | On-premises or regulated environments |
| **GitHub Releases** | Attach evidence PDFs as release assets; reference via the GitHub release download URL | Projects that already use GitHub Releases for distribution |

### Suggested Directory Structure

When storing evidence PDFs in a repository, a consistent directory layout makes it straightforward
to manage the `index.json` and locate individual reviews:

```
evidence/
  index.json
  reviews/
    2025-01-15-core-logic-v1.2.0.pdf
    2025-01-15-security-layer-v1.2.0.pdf
    2025-03-01-core-logic-v1.3.0.pdf
```

The `index.json` is maintained by `reviewmark --index "evidence/**/*.pdf"` and references each PDF
by its SHA256 fingerprint and the files it covers.

## Digital Signing of Review Evidence

For regulated environments where review evidence must be non-repudiation-proof, digital signing of
review PDFs is strongly recommended. A signed PDF proves that a named, authenticated individual
reviewed a specific document at a specific time, and that the document has not been altered since.

### Free Signing Services

| Service | Description |
| :------ | :---------- |
| [DocuSeal](https://www.docuseal.com/) | Open-source document signing platform; free tier available; preserves PDF metadata; used by DEMA Consulting |
| [DocuSign Free](https://www.docusign.com/) | Industry-standard e-signature platform with a limited free tier |
| [Adobe Acrobat Sign](https://acrobat.adobe.com/us/en/sign.html) | Adobe's e-signature service; free trial available |

[DocuSeal](https://www.docuseal.com/) is particularly relevant for open-source and smaller teams:
it is itself open-source, can be self-hosted, preserves PDF metadata, and produces signed PDFs that
are verifiable without proprietary tooling. DEMA Consulting uses DocuSeal, storing signed review
PDFs in a `reviews` branch of the repository under review.

### Signing Workflow

A typical signing workflow for review evidence integrates with the CI/CD pipeline:

1. **Generate** — the pipeline generates or updates the document(s) to be reviewed
2. **Submit for signing** — the review evidence PDF is submitted to the signing service
3. **Notify reviewers** — the signing service sends email or API notification to named reviewers
4. **Sign** — reviewers sign the document through the signing service portal
5. **Store** — the signed PDF is stored in the evidence store
6. **Re-index** — `reviewmark --index` updates `index.json` with the signed PDF's fingerprint
7. **Verify** — subsequent pipeline runs confirm the signed review is current

This workflow ensures that each review is tied to an authenticated individual, timestamped, and
tamper-evident, satisfying the documentation requirements of standards such as IEC 62443, DO-178C,
and ISO 26262.

## AI-Assisted Reviews

Review-sets serve a dual purpose in Continuous Compliance projects. Beyond their primary role as
compliance evidence units, they are a natural grouping mechanism for AI-assisted code reviews.

### Review-Sets as Context Boundaries

A well-designed review-set groups all files that belong together conceptually: requirements
documents, design documents, source code, and tests that collectively form a coherent unit of
functionality. An AI agent directed to review all files in a review-set at once can comprehend
the full chain of evidence:

- **Requirements** — what the code must do and why
- **Design documents** — how the code is structured and the rationale behind key decisions
- **Source code** — what the code actually does
- **Tests** — which behaviors are verified and how

With this context, the agent can identify inconsistencies between requirements and implementation,
gaps in test coverage relative to stated requirements, undocumented design decisions, and
requirements that are stated but not tested. This produces far more constructive review
recommendations than reviewing any single file category in isolation.

### Designing Review-Sets for AI Context

To maximize the usefulness of review-sets for AI-assisted reviews, group files by feature or
functional area rather than by file type:

In the example below, requirements files are placed under `docs/reqstream/`. This is a recommended
convention for downstream projects: create this directory in your own repository (or adjust the
paths) so that they point to wherever your requirements actually live.

```yaml
reviews:
  - id: Authentication
    title: Authentication and authorization subsystem
    paths:
      - "docs/reqstream/auth-requirements.yaml"      # requirements
      - "docs/design/auth-design.md"               # design
      - "src/Auth/**/*.cs"                          # implementation
      - "tests/Auth/**/*.cs"                        # tests

  - id: Core-Engine
    title: Core processing engine
    paths:
      - "docs/reqstream/engine-requirements.yaml"
      - "docs/design/engine-design.md"
      - "src/Core/**/*.cs"
      - "tests/Core/**/*.cs"
```

When an AI agent reviews the `Authentication` review-set, it reads the requirements that define
expected behavior, the design that explains the implementation approach, the source code that
provides the actual implementation, and the tests that verify compliance — all in one context.
The agent can answer questions that cross these boundaries: "Does the implementation match the
requirements?", "Are all requirements covered by tests?", "Is the design documentation current?".

### Subsystem Reviews and Software Unit Reviews

When requirements contain both subsystem-requirements (describing cross-cutting concerns and
subsystems) and design-requirements (describing the behavior of specific software units), two
complementary types of review-sets are useful.

In this documentation, the term **software unit** is used in the IEC 62304 sense (a software
item that is not subdivided into other components) that typically maps to an individual class or
module. **Subsystem-requirements** describe behavior of cross-cutting
subsystems that span multiple such software units.

**Subsystem reviews** group files related to a cross-cutting concern or subsystem that spans
multiple classes or modules. Examples include command-line argument processing, logging
infrastructure, user interface components, and security enforcement. A subsystem review typically
covers all requirements, documentation, and implementation files that contribute to that
subsystem, regardless of how many classes are involved.

**Software unit reviews** group files related to a specific class, module, or component —
typically one review-set per class. When requirements include design-requirements that specify
how an individual unit must behave, a software unit review provides focused coverage: the
unit's requirements, its source file, and its direct tests.

This two-tier approach handles projects where the requirements document both high-level
subsystems and detailed per-class behavior:

```yaml
reviews:
  # Subsystem reviews — cross-cutting subsystems
  - id: CommandLineProcessing
    title: Review of command-line argument parsing
    paths:
      - "docs/reqstream/cli-requirements.yaml"
      - "docs/design/cli-design.md"
      - "src/**/CommandLine*.cs"
      - "src/**/ArgumentParser*.cs"
      - "tests/**/CommandLine*.cs"

  - id: Logging
    title: Review of logging infrastructure
    paths:
      - "docs/reqstream/logging-requirements.yaml"
      - "docs/design/logging-design.md"
      - "src/**/Logger*.cs"
      - "src/**/Log*.cs"
      - "tests/**/Log*.cs"

  # Software unit reviews — one per class
  - id: UserService
    title: Review of UserService class
    paths:
      - "docs/reqstream/user-service-requirements.yaml"
      - "docs/design/user-service-design.md"
      - "src/Services/UserService.cs"
      - "tests/Services/UserServiceTests.cs"

  - id: OrderRepository
    title: Review of OrderRepository class
    paths:
      - "docs/reqstream/order-repository-requirements.yaml"
      - "docs/design/order-repository-design.md"
      - "src/Data/OrderRepository.cs"
      - "tests/Data/OrderRepositoryTests.cs"
```

Subsystem reviews are appropriate when a requirement addresses a concern implemented across many
files, making it impractical to assign that requirement to a single software unit review.
Software unit reviews are appropriate when design-requirements specify the precise behavior of
a single class, enabling a reviewer — human or AI — to verify each requirement against its
direct implementation and tests without noise from unrelated files.

### Standard Review-Set Patterns

Projects following DEMA Consulting standards use a set of named review-set types that agents and
reviewers can recognize and rely upon:

| Review-Set Type | ID Pattern | Contents |
| :-------------- | :--------- | :------- |
| **System** | `[Project]-System` | System-level requirements, design introduction, system design documents, integration tests |
| **Design** | `[Product]-Design` | System-level requirements, platform requirements, all design documents |
| **All Requirements** | `[Product]-AllRequirements` | All requirement files including root `requirements.yaml` |
| **Unit** | `[Product]-[Unit]` | Unit requirements, design documents, source code, unit tests |

A typical project would have one System review, one Design review, one AllRequirements review, and
one Unit review per software unit (class). This structure gives reviewers — and review agents — a
predictable set of entry points into the codebase:

```yaml
reviews:
  - id: MyProduct-System
    title: System Integration Review
    paths:
      - "docs/reqstream/myproduct-system.yaml"
      - "docs/design/introduction.md"
      - "docs/design/system.md"
      - "tests/**/IntegrationTests.cs"

  - id: MyProduct-Design
    title: Architecture and Design Review
    paths:
      - "docs/reqstream/myproduct-system.yaml"
      - "docs/reqstream/platform-requirements.yaml"
      - "docs/design/**/*.md"

  - id: MyProduct-AllRequirements
    title: All Requirements Review
    paths:
      - "requirements.yaml"
      - "docs/reqstream/**/*.yaml"

  - id: MyProduct-MyComponent
    title: MyComponent Unit Review
    paths:
      - "docs/reqstream/unit-mycomponent.yaml"
      - "docs/design/mycomponent.md"
      - "src/MyComponent.cs"
      - "tests/MyComponentTests.cs"
```

### Using ReviewMark with AI Review Agents

The `.reviewmark.yaml` configuration makes the file grouping explicit and machine-readable, which
allows an AI agent to identify and retrieve the complete context for any review-set automatically.
A review agent workflow can:

1. Read `.reviewmark.yaml` to discover the defined review-sets
2. Select a review-set by its `id`
3. Load all files matching the review-set's `paths` patterns
4. Perform the review with complete context
5. Generate a structured review report covering requirements coverage, design currency, and
   implementation correctness

This is more reliable than asking an agent to "review the authentication module" without explicit
scope, because the `.reviewmark.yaml` precisely and authoritatively defines which files belong to
that scope.

## Self-Validation

ReviewMark includes built-in self-validation tests:

```bash
dotnet reviewmark --validate --results artifacts/reviewmark-self-validation.trx
```

These tests verify ReviewMark's own functionality — fingerprinting, plan generation, report
generation, index scanning, and enforcement — and produce test evidence that can be used by
[ReqStream](requirements.md) to validate ReviewMark's own requirements.

## Generated Documents

ReviewMark generates two markdown documents:

### Review Plan

Shows which files are covered by which review-sets, and flags any files not covered by any review:

```markdown
# Review Plan

## Core-Logic

**Title:** Review of core business logic

| File | Status |
| :--- | :----- |
| src/Core/Engine.cs | ✅ Covered |
| src/Core/Parser.cs | ✅ Covered |

## Security-Layer

**Title:** Review of authentication and authorization

| File | Status |
| :--- | :----- |
| src/Auth/AuthService.cs | ✅ Covered |

## Uncovered Files

| File |
| :--- |
| src/Utils/Helper.cs |
```

### Review Report

Shows the status of each review-set — whether the evidence is current, stale, or missing:

```markdown
# Review Report

| Review | Title | Status |
| :----- | :---- | :----- |
| Core-Logic | Review of core business logic | ✅ Current |
| Security-Layer | Review of authentication and authorization | ⚠️ Stale |
```
