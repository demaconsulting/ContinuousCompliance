# Tool Version Capture

Knowing exactly which tool versions were used to produce a build is essential for reproducibility,
auditability, and debugging. When a defect is found in a release, the first question is always: "What
tools built it?" When a build fails intermittently, the answer is often a tool version difference between
environments.

[DemaConsulting.VersionMark](https://github.com/demaconsulting/VersionMark) solves this by capturing and
publishing tool version information automatically in every CI/CD run.

## How It Works

The capture process runs in two phases:

**Phase 1 – Capture (per job):** Each CI/CD job captures the versions of the tools it uses and saves
them to a per-job JSON file:

```bash
dotnet versionmark \
  --capture \
  --job-id "build-ubuntu" \
  --output "artifacts/versionmark-build-ubuntu.json" \
  -- dotnet git
```

**Phase 2 – Publish (document generation job):** After all jobs complete, the per-job JSON files are
consolidated into a single markdown versions report:

```bash
dotnet versionmark \
  --publish \
  --report docs/buildnotes/versions.md \
  --report-depth 1 \
  -- "artifacts/**/versionmark-*.json"
```

VersionMark highlights any version discrepancies between jobs — for example, if the Windows and Linux
build jobs used different versions of the .NET SDK.

## Configuration

Tool definitions are stored in `.versionmark.yaml` at the repository root. Each entry specifies how to
invoke the tool and how to extract its version string:

```yaml
tools:
  dotnet:
    command: dotnet --version
    regex: '(?<version>\d+\.\d+\.\d+)'

  git:
    command: git --version
    regex: 'git version (?<version>\d+\.\d+\.\d+)'

  node:
    command: node --version
    regex: 'v(?<version>\d+\.\d+\.\d+)'
```

Platform-specific command overrides are supported for tools that behave differently across operating
systems.

## Output

The published versions report is included in the **Build Notes** PDF for every release:

```markdown
## Tool Versions

- **dotnet**: 10.0.100
- **git**: 2.43.0 (build-ubuntu)
- **git**: 2.44.0 (build-windows)
- **node**: 22.11.0
```

When a tool has the same version across all jobs it is listed once. When versions differ, each version
is shown with the job identifier in parentheses.

## Self-Validation

VersionMark includes built-in self-validation tests that verify it is functioning correctly without
requiring a live environment:

```bash
dotnet versionmark --validate --results artifacts/versionmark-self-validation.trx
```

The resulting TRX file is consumed by [ReqStream](requirements.md) as test evidence for VersionMark's
own requirements.
