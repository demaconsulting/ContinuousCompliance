# Self-Validation

Each DEMA Consulting tool includes a built-in `--validate` command that runs self-validation tests
without requiring external services, live servers, or real repositories. Self-validation serves two
distinct purposes:

1. **Verification** — Confirms that the installed version of the tool functions correctly in the
   target environment. This is particularly valuable for integration testing across multiple operating
   systems and .NET runtime versions.

2. **Test Evidence** — Produces TRX or JUnit test result files that
   [ReqStream](requirements.md) uses as test coverage evidence for the tool's own requirements.

This creates a self-consistent compliance loop: the tools that implement Continuous Compliance are
themselves validated using the same Continuous Compliance infrastructure.

## Self-Validation Commands

| Tool | Command |
| :--- | :------ |
| [VersionMark](https://github.com/demaconsulting/VersionMark) | `dotnet versionmark --validate --results results.trx` |
| [SonarMark](https://github.com/demaconsulting/SonarMark) | `dotnet sonarmark --validate --results results.trx` |
| [SarifMark](https://github.com/demaconsulting/SarifMark) | `dotnet sarifmark --validate --results results.trx` |
| [ReqStream](https://github.com/demaconsulting/ReqStream) | `dotnet reqstream --validate --results results.trx` |
| [BuildMark](https://github.com/demaconsulting/BuildMark) | `dotnet buildmark --validate --results results.trx` |

## CI/CD Integration

Self-validation runs at two points in the pipeline:

### During the Build Job

The tool under test is not yet available, so the pipeline validates the tooling dependencies instead.
VersionMark self-validation typically runs here:

```yaml
- name: Run VersionMark self-validation
  run: dotnet versionmark --validate --results artifacts/versionmark-self-validation-${{ matrix.os }}.trx
```

### During Integration Testing

After the tool is built and packaged, it is installed from the NuGet package and self-validated across
a matrix of operating systems and .NET runtime versions:

```yaml
- name: Run self-validation
  run: |
    templatetool --validate \
      --results artifacts/validation-${{ matrix.os }}-dotnet${{ matrix.dotnet-version }}.trx
```

This produces one TRX file per OS/runtime combination, all of which are collected and fed into
ReqStream in the document generation job.

### During Document Generation

All remaining tool self-validations run in the document generation job to produce evidence for those
tools' own requirements:

```yaml
- name: Run ReqStream self-validation
  run: dotnet reqstream --validate --results artifacts/reqstream-self-validation.trx

- name: Run BuildMark self-validation
  run: dotnet buildmark --validate --results artifacts/buildmark-self-validation.trx

- name: Run SarifMark self-validation
  run: dotnet sarifmark --validate --results artifacts/sarifmark-self-validation.trx

- name: Run SonarMark self-validation
  run: dotnet sonarmark --validate --results artifacts/sonarmark-self-validation.trx
```

## Self-Validation Output

Running self-validation produces a summary report:

```text
# DEMA Consulting TemplateDotNetTool

| Information         | Value                              |
| :------------------ | :--------------------------------- |
| Tool Version        | 1.2.3                              |
| Machine Name        | runner-host                        |
| OS Version          | Ubuntu 24.04                       |
| DotNet Runtime      | 10.0.0                             |
| Time Stamp          | 2026-01-15 10:23:45 UTC            |

✓ TemplateTool_VersionDisplay - Passed
✓ TemplateTool_HelpDisplay - Passed

Total Tests: 2
Passed: 2
Failed: 0
```

The tool exits with code 0 on success and a non-zero code if any test fails, making it suitable for
use as a pipeline gate.
