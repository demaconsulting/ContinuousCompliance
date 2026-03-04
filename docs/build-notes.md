# Build Notes Generation

Build notes document the changes included in a release: what was added, what was fixed, and what issues
remain open. Manually maintaining release notes is tedious and error-prone; important changes are
forgotten, or the notes fall out of date with the actual code history.

[DemaConsulting.BuildMark](https://github.com/demaconsulting/BuildMark) generates build notes
automatically from Git history and GitHub issues, ensuring they accurately reflect the actual changes
between releases.

## How It Works

BuildMark analyses the Git repository history between the previous release tag and the current version,
fetching associated GitHub issues and pull requests to populate the change list.

```bash
dotnet buildmark \
  --build-version ${{ inputs.version }} \
  --report docs/buildnotes.md \
  --report-depth 1
```

The `--include-known-issues` flag adds an open issues section to the report:

```bash
dotnet buildmark \
  --build-version v1.2.3 \
  --report docs/buildnotes.md \
  --report-depth 1 \
  --include-known-issues
```

## Generated Report

The output markdown report includes:

```markdown
# Build Report

## Version Information

**Version:** 1.2.3
**Baseline Version:** 1.2.0
**Commit:** abc123def456

## Changes

- [#42](https://github.com/owner/repo/pull/42): Add self-validation support
- [#43](https://github.com/owner/repo/pull/43): Improve error messages

## Bugs Fixed

- [#40](https://github.com/owner/repo/issues/40): Fix crash on empty input
- [#41](https://github.com/owner/repo/issues/41): Correct version comparison logic

## Known Issues

- [#44](https://github.com/owner/repo/issues/44): Performance degradation on large files

## Complete Changelog

[View Full Changelog](https://github.com/owner/repo/compare/v1.2.0...v1.2.3)
```

## Tool Versions

In addition to the build notes, the [VersionMark](tool-versions.md) tool publishes a versions report
into the same build notes document set, recording the exact tool versions used in the build:

```bash
dotnet versionmark \
  --publish \
  --report docs/buildnotes/versions.md \
  --report-depth 1 \
  -- "artifacts/**/versionmark-*.json"
```

Both the build notes and the tool versions report are combined into the **Build Notes PDF** released
with every version.

## CI/CD Integration

BuildMark requires a `GH_TOKEN` to fetch GitHub issue and pull request data:

```yaml
- name: Generate Build Notes with BuildMark
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: >
    dotnet buildmark
    --build-version ${{ inputs.version }}
    --report docs/buildnotes.md
    --report-depth 1
```

The `GITHUB_TOKEN` secret is provided automatically by GitHub Actions and is sufficient for accessing
public repository data.

## Self-Validation

BuildMark includes built-in self-validation tests that verify its functionality using mock repository
data:

```bash
dotnet buildmark --validate --results artifacts/buildmark-self-validation.trx
```

These tests verify version tag parsing, build information extraction, and markdown report generation
without requiring access to a real repository or GitHub.
