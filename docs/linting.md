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

Template configuration files are provided in [`templates/lint/`](../templates/lint/) and should be
copied to the repository root when setting up linting for a new project.

### markdownlint-cli2

Markdown linting is configured via [`.markdownlint-cli2.yaml`](../templates/lint/.markdownlint-cli2.yaml)
at the repository root. Key configuration highlights:

- All default markdownlint rules are enabled
- ATX-style headers (`# Header`) are required instead of Setext-style
- Line length is capped at 120 characters to allow URLs and technical content
- Multiple top-level headers, inline HTML, and documents without a top-level header are permitted

See the [markdownlint rules reference](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md)
for the full list of available rules.

### cspell

Spell-checking is configured via [`.cspell.yaml`](../templates/lint/.cspell.yaml) at the repository
root. Key configuration highlights:

- Includes a project word list of common technical terms (tool names, identifiers) to prevent false positives
- Excludes build artifacts and dependency directories (`node_modules`, `.git`, `bin`, `obj`, `.venv`)
- The word list should be extended with any project-specific terms as the project grows

### yamllint

YAML linting is configured via [`.yamllint.yaml`](../templates/lint/.yamllint.yaml) at the repository
root. Key configuration highlights:

- Extends the yamllint default rule set
- Allows `on:` and `off:` as non-boolean values (required for GitHub Actions workflow keys)
- Line length is capped at 120 characters
- Enforces 2-space indentation and requires at least 2 spaces before inline comments

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

Linting can also be run locally using the scripts provided in [`templates/lint/`](../templates/lint/):

```bash
# Linux/macOS
./lint.sh

# Windows
lint.bat
```

These scripts install all required dependencies (npm packages and yamllint via Python venv) and run
all three linters against the repository, enabling developers to catch and fix issues before pushing.
