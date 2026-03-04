# Requirements Enforcement

Requirements enforcement ensures that every stated requirement for a project is covered by at least one
passing test. This closes the loop between "what the software must do" and "proof that it does it" —
the foundation of any compliance regime.

[DemaConsulting.ReqStream](https://github.com/demaconsulting/ReqStream) manages requirements defined in
YAML files, validates test coverage, and generates requirements documentation, justifications, and a
trace matrix.

## Requirements File Format

Requirements are defined in YAML files with a hierarchical section structure:

```yaml
---
sections:
  - title: Functional Requirements
    requirements:
      - id: FUNC-001
        title: The tool shall display version information.
        justification: |
          Users need to verify which version of the tool is installed. This is
          particularly important for regulated environments where software versions
          must be recorded.
        tests:
          - TemplateTool_VersionDisplay

      - id: FUNC-002
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
| `id` | Yes | Unique requirement identifier (any format) |
| `title` | Yes | The requirement statement |
| `justification` | No | Rationale explaining why this requirement exists |
| `tests` | No | List of test names that satisfy this requirement |
| `children` | No | IDs of child requirements (coverage propagates up) |
| `tags` | No | Labels for filtering (e.g., `security`, `compliance`) |

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
  - windows-latest@Test_WindowsSpecificFeature  # Only matches windows-latest.trx
  - ubuntu@Test_LinuxSpecificFeature           # Only matches files containing "ubuntu"
  - Test_CrossPlatformFeature                  # Aggregates from all result files
```

## Generated Documents

ReqStream generates three markdown documents:

### Requirements Report

Lists all requirements organized by section, with their IDs and titles. Example output:

```markdown
# Functional Requirements

## FUNC-001

The tool shall display version information.

## FUNC-002

The tool shall display usage help information.
```

### Requirements Justifications

Lists all requirements with their justification text — the rationale behind each requirement. This
document is valuable for compliance reviews and audits.

### Trace Matrix

Shows the coverage status of every requirement:

| ID | Title | Tests | Status |
| :- | :---- | :---- | :----- |
| FUNC-001 | The tool shall display version information. | TemplateTool_VersionDisplay | ✅ Satisfied |
| FUNC-002 | The tool shall display usage help information. | TemplateTool_HelpDisplay | ✅ Satisfied |

## Self-Validation

ReqStream includes built-in self-validation tests:

```bash
dotnet reqstream --validate --results artifacts/reqstream-self-validation.trx
```

These tests verify ReqStream's own functionality and produce test evidence that ReqStream uses to
validate its own requirements — demonstrating that the approach is self-consistent.
