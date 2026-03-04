# Linting

Linting is the first stage of every CI/CD pipeline run. It enforces consistent style and formatting across
all documentation, source code, and configuration files, ensuring that quality problems are caught at the
earliest possible point in the development process.

Linting failures block all downstream pipeline stages, preventing lower-quality code or documentation from
progressing further.

## Tools

| Tool | Scope | Purpose |
| :--- | :---- | :------ |
| [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2) | `**/*.md` | Markdown style and formatting rules |
| [cspell](https://github.com/streetsidesoftware/cspell) | `**/*.{md,cs}` | Spell-checking across documentation and source files |
| [yamllint](https://github.com/adrienverge/yamllint) | `**/*.yaml`, `**/*.yml` | YAML structure, indentation, and formatting |

## Configuration

### markdownlint-cli2

Markdown linting is configured via `.markdownlint-cli2.jsonc` at the repository root. This file enables
or disables specific rules and configures rule options:

```jsonc
{
  "config": {
    "default": true,
    "MD013": false  // Line length - disabled to allow natural prose
  }
}
```

Rules are inherited from the [markdownlint](https://github.com/DavidAnson/markdownlint) rule set.
See the [markdownlint rules reference](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md)
for the full list of available rules.

### cspell

Spell-checking is configured via `.cspell.json` at the repository root. Project-specific terms
(tool names, identifiers, acronyms) are added to the project word list to prevent false positives:

```json
{
  "version": "0.2",
  "language": "en",
  "words": [
    "DemaConsulting",
    "SonarMark",
    "SarifMark",
    "ReqStream",
    "VersionMark",
    "BuildMark"
  ],
  "ignorePaths": [
    "node_modules",
    "**/*.json"
  ]
}
```

### yamllint

YAML linting is configured via `.yamllint.yaml` at the repository root:

```yaml
extends: default
rules:
  line-length:
    max: 120
  truthy:
    allowed-values: ['true', 'false']
```

## CI/CD Integration

In the DEMA Consulting pipeline the linting stage is implemented as the `quality-checks` job in the
reusable build workflow. It runs on every push and pull request:

```yaml
- name: Run markdown linter
  uses: DavidAnson/markdownlint-cli2-action@v22
  with:
    globs: '**/*.md'

- name: Run spell checker
  uses: streetsidesoftware/cspell-action@v8
  with:
    files: '**/*.{md,cs}'
    incremental_files_only: false

- name: Run YAML linter
  uses: ibiqlik/action-yamllint@v3
  with:
    config_file: .yamllint.yaml
```

## Running Locally

Linting can also be run locally using the provided shell scripts:

```bash
# Linux/macOS
./lint.sh

# Windows
lint.bat
```

These scripts run all three linters against the repository using the same configuration as the CI/CD
pipeline, enabling developers to catch and fix issues before pushing.
