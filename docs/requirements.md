# Requirements Enforcement

Requirements enforcement ensures that every stated requirement for a project is covered by at least one
passing test. This closes the loop between "what the software must do" and "proof that it does it" —
the foundation of any compliance regime.

[DemaConsulting.ReqStream](https://github.com/demaconsulting/ReqStream) manages requirements defined in
YAML files, validates test coverage, and generates requirements documentation, justifications, and a
trace matrix.

## Template Files

The `templates/reqstream` folder provides ready-to-use template files for a new project:

- [`.config/dotnet-tools.json`][reqstream-dotnet-tools] — registers the `dotnet reqstream` tool via
  .NET local tool manifest
- [`requirements.yaml`][reqstream-root] — root requirements file that includes all files from
  `docs/reqstream/`
- [`docs/reqstream/subsystem-example.yaml`][reqstream-subsystem-example] — example software subsystem
  requirements
- [`docs/reqstream/unit-example.yaml`][reqstream-unit-example] — example software unit requirements
- [`docs/reqstream/ots-example.yaml`][reqstream-ots-example] — example OTS (off-the-shelf) software
  requirements

[reqstream-dotnet-tools]: https://github.com/demaconsulting/ContinuousCompliance/blob/main/templates/reqstream/.config/dotnet-tools.json
[reqstream-root]: https://github.com/demaconsulting/ContinuousCompliance/blob/main/templates/reqstream/requirements.yaml
[reqstream-subsystem-example]: https://github.com/demaconsulting/ContinuousCompliance/blob/main/templates/reqstream/docs/reqstream/subsystem-example.yaml
[reqstream-unit-example]: https://github.com/demaconsulting/ContinuousCompliance/blob/main/templates/reqstream/docs/reqstream/unit-example.yaml
[reqstream-ots-example]: https://github.com/demaconsulting/ContinuousCompliance/blob/main/templates/reqstream/docs/reqstream/ots-example.yaml

The recommended approach is to keep a separate requirements YAML file per software system, subsystem,
unit, or OTS component under `docs/reqstream/`, and list them in `requirements.yaml` using the
`includes` field. A consistent naming convention makes the scope of each file immediately clear:

```text
docs/reqstream/
  {project}-system.yaml         # System-level requirements
  subsystem-{name}.yaml         # Subsystem requirements
  unit-{name}.yaml              # Software unit (class-level) requirements
  ots-{component}.yaml          # OTS software item requirements
```

This keeps each file focused on one component and makes reviews easier.

## Requirement Classes

Requirements fall into four classes based on the component they describe:

### Software System Requirements

System requirements describe the complete deliverable product from the perspective of its external
users and interfaces. They capture what the system as a whole must do — its observable behaviors,
qualities, and constraints — without specifying how any individual subsystem or unit implements
them. System requirements are satisfied when end-to-end or integration tests demonstrate that the
product meets its stated obligations.

The recommended approach is to keep system-level requirements in a dedicated file (e.g.,
`docs/reqstream/{project}-system.yaml`) separate from subsystem and unit requirements.

### Software Subsystem Requirements

Subsystem requirements describe the externally visible behavior of a component — what it does from
the perspective of its callers, without specifying how it is implemented internally. A subsystem is
typically a module, service, or library boundary. Subsystem requirements are satisfied when the
component's observable behavior matches the stated requirement, as demonstrated by passing tests.

### Software Unit Requirements

Unit requirements describe precise, implementation-level behavior of the smallest independently
testable components — typically a class or method. Unit requirements are verified by unit tests that
exercise the component in isolation.

### OTS (Off-the-Shelf) Software Requirements

OTS requirements document the functionality that the project needs from a third-party component, such
as a library, framework, or commercial tool. These requirements make explicit which OTS capabilities
the project depends on, enabling review and replacement decisions. OTS requirements are satisfied by
tests (typically smoke or integration tests) that demonstrate the OTS component provides the required
behavior in the project's environment.

## Requirements File Format

Requirements are defined in YAML files with a hierarchical section structure:

```yaml
---
sections:
  - title: Functional Requirements
    requirements:
      - id: TemplateTool-Core-Version
        title: The tool shall display version information.
        justification: |
          Users need to verify which version of the tool is installed. This is
          particularly important for regulated environments where software versions
          must be recorded.
        tests:
          - TemplateTool_VersionDisplay

      - id: TemplateTool-Core-Help
        title: The tool shall display usage help information.
        justification: |
          Users must be able to discover the available options without consulting
          external documentation.
        tests:
          - TemplateTool_HelpDisplay
```

### Key Fields

| Field | Required | Description |
| :---- | :------- | :---------- |
| `id` | Yes | Unique requirement identifier; prefer semantic IDs (see below) |
| `title` | Yes | The requirement statement |
| `justification` | No | Rationale explaining why this requirement exists |
| `tests` | No | List of test names that satisfy this requirement |
| `children` | No | IDs of child requirements (coverage propagates up) |
| `tags` | No | Labels for filtering (e.g., `security`, `compliance`) |

### Choosing Requirement IDs

Requirement IDs appear in trace matrices, generated reports, code comments, and test names. A
semantic ID communicates meaning at the point of reference — without having to look up what the
ID means.

Prefer a `Project-System-ShortDescription` format:

- **`MyApp-Auth-PasswordMinLength`** is self-explanatory wherever it appears.
- **`REQ-042`** requires a lookup to understand.

Good IDs are:

- **Unique** — no two requirements share the same ID.
- **Stable** — avoid IDs that encode a sequence number or date that may need to change.
- **Descriptive** — a reader unfamiliar with the project can infer the requirement's subject from
  the ID alone.

The examples in this document follow this pattern — `TemplateTool-Core-Version` and
`TemplateTool-Core-Help` identify requirements by project (`TemplateTool`), subsystem (`Core`),
and feature (`Version`, `Help`).

Requirements can also reference tests defined in a separate `mappings` section, or in included files,
allowing test mappings to be kept separately from requirement definitions.

## CI/CD Integration

ReqStream runs in the document generation job after all test results have been collected:

```bash
dotnet reqstream \
  --requirements requirements.yaml \
  --tests "artifacts/**/*.trx" \
  --report docs/requirements/requirements.md \
  --justifications docs/justifications/justifications.md \
  --matrix docs/tracematrix/tracematrix.md \
  --enforce
```

The `--enforce` flag causes the pipeline to fail with a non-zero exit code if any requirement is not
satisfied. The error message reports how many requirements are unsatisfied:

```text
Error: Only 14 of 16 requirements are satisfied with tests.
```

Reports are always generated before enforcement fails, so the trace matrix is available to diagnose
which requirements are not covered.

## Test Source Linking

When running tests across multiple platforms or configurations, test result files include platform
identifiers in their names (e.g., `windows-latest.trx`, `ubuntu-latest.trx`). ReqStream supports
source-specific test matching to associate requirements with tests from specific result files:

```yaml
tests:
  - windows-latest@Test_WindowsSpecificFeature  # Only matches files containing windows-latest
  - ubuntu@Test_LinuxSpecificFeature           # Only matches files containing "ubuntu"
  - Test_CrossPlatformFeature                  # Aggregates from all result files
```

## Generated Documents

ReqStream generates three markdown documents:

### Requirements Report

Lists all requirements organized by section, with their IDs and titles. Example output:

```markdown
# Functional Requirements

## TemplateTool-Core-Version

The tool shall display version information.

## TemplateTool-Core-Help

The tool shall display usage help information.
```

### Requirements Justifications

Lists all requirements with their justification text — the rationale behind each requirement. This
document is valuable for compliance reviews and audits.

### Trace Matrix

Shows the coverage status of every requirement:

| ID | Title | Tests | Status |
| :- | :---- | :---- | :----- |
| TemplateTool-Core-Version | The tool shall display version information. | TemplateTool_VersionDisplay | ✅ Satisfied |
| TemplateTool-Core-Help | The tool shall display usage help information. | TemplateTool_HelpDisplay | ✅ Satisfied |

## Self-Validation

ReqStream includes built-in self-validation tests:

```bash
dotnet reqstream --validate --results artifacts/reqstream-self-validation.trx
```

These tests verify ReqStream's own functionality and produce test evidence that ReqStream uses to
validate its own requirements — demonstrating that the approach is self-consistent.
