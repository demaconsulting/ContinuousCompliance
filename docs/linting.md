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

Template configuration files are provided in [`templates/lint/`](https://github.com/demaconsulting/ContinuousCompliance/tree/main/templates/lint) and should be
copied to the repository root when setting up linting for a new project.

### markdownlint-cli2

Markdown linting is configured via [`.markdownlint-cli2.yaml`](https://github.com/demaconsulting/ContinuousCompliance/blob/main/templates/lint/.markdownlint-cli2.yaml)
at the repository root. Key configuration highlights:

- All default markdownlint rules are enabled
- ATX-style headers (`# Header`) are required instead of Setext-style
- Line length is capped at 120 characters to allow URLs and technical content
- Multiple top-level headers, inline HTML, and documents without a top-level header are permitted

See the [markdownlint rules reference](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md)
for the full list of available rules.

### cspell

Spell-checking is configured via [`.cspell.yaml`](https://github.com/demaconsulting/ContinuousCompliance/blob/main/templates/lint/.cspell.yaml) at the repository
root. Key configuration highlights:

- Includes a project word list of common technical terms (tool names, identifiers) to prevent false positives
- Excludes build artifacts and dependency directories (`node_modules`, `.git`, `bin`, `obj`, `.venv`)
- The word list should be extended with any project-specific terms as the project grows

### yamllint

YAML linting is configured via [`.yamllint.yaml`](https://github.com/demaconsulting/ContinuousCompliance/blob/main/templates/lint/.yamllint.yaml) at the repository
root. Key configuration highlights:

- Extends the yamllint default rule set
- Allows `on:` and `off:` as non-boolean values (required for GitHub Actions workflow keys)
- Line length is capped at 120 characters
- Enforces 2-space indentation and requires at least 2 spaces before inline comments

### package.json

The npm dependencies (`cspell` and `markdownlint-cli2`) are declared in
[`package.json`](https://github.com/demaconsulting/ContinuousCompliance/blob/main/templates/lint/package.json).
If the consuming project already has a `package.json`, merge the linting tools into its existing
`devDependencies` rather than replacing the file:

```json
"devDependencies": {
  "cspell": "9.7.0",
  "markdownlint-cli2": "0.21.0"
}
```

## Running Linting

The lint scripts provided in [`templates/lint/`](https://github.com/demaconsulting/ContinuousCompliance/tree/main/templates/lint) are the single source of truth
for linting — they are used both locally by developers and by the CI/CD pipeline, ensuring rules are
defined in only one place.

```yaml
- name: Run linters
  shell: bash
  run: bash ./lint.sh
```

Running locally on Linux/macOS:

```bash
bash ./lint.sh
```

Running locally on Windows:

```bat
lint.bat
```

The scripts install all required dependencies (npm packages and yamllint via Python venv) and run
all three linters, exiting non-zero on any failure.
