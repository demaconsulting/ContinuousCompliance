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

- Includes a project word list of genuine technical terms (tool names, identifiers) to prevent false positives
- Excludes build artifacts and dependency directories (`node_modules`, `.git`, `bin`, `obj`, `.venv`)

#### Word list policy

**Never** add a word to the `.cspell.yaml` word list in order to silence a spell-checking failure.
Doing so defeats the purpose of spell-checking and reduces the quality of the repository.

- If cspell flags a word that is **misspelled**, fix the spelling in the source file.
- If cspell flags a word that is a **genuine technical term** (tool name, project identifier, etc.) and is
  spelled correctly, raise a **proposal** (e.g. open an issue or pull request) explaining why the word
  should be added. The proposal must be reviewed and approved before the word is added to the list.

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
`devDependencies` rather than replacing the file. The versions below reflect the current template;
always use the versions from the template file when adopting the toolchain:

```json
"devDependencies": {
  "cspell": "9.7.0",
  "markdownlint-cli2": "0.21.0"
}
```

### pip-requirements.txt

The pip dependencies (`yamllint` and `yamlfix`) are declared in
[`pip-requirements.txt`](https://github.com/demaconsulting/ContinuousCompliance/blob/main/templates/lint/pip-requirements.txt).
This file follows the standard pip requirements file format and is installed into a Python virtual
environment by the lint scripts, which expect to install from `pip-requirements.txt` by default.
When you copy `lint.ps1` and `fix.ps1` from `templates/lint/` into a repository, you must also copy
`pip-requirements.txt` alongside them so the scripts' `pip install -r pip-requirements.txt` step can succeed.

If your project already uses `pip-requirements.txt`, add `yamllint` and `yamlfix` pinned to the versions specified
in the template file:

```text
yamllint==1.38.0
yamlfix==1.19.1
```

If your project keeps its Python dependencies in a differently named file (for example, `requirements.txt`),
either:

- Add `yamllint` and `yamlfix` to that existing requirements file and update `lint.ps1` and `fix.ps1` to install from it
  instead of `pip-requirements.txt`, or
- Keep a separate `pip-requirements.txt` alongside your existing file, containing at least `yamllint` and any
  other lint-only Python tools you want the scripts to install.

The file is named `pip-requirements.txt` rather than the conventional `requirements.txt` because
Continuous Compliance repositories have Business and Software requirements documents, and a root-level
`requirements.txt` would be ambiguous. The `pip-` prefix makes the purpose of the file clear.

## Running Linting

The lint scripts provided in [`templates/lint/`](https://github.com/demaconsulting/ContinuousCompliance/tree/main/templates/lint) are the single source of truth
for linting — they are used both locally by developers and by the CI/CD pipeline, ensuring rules are
defined in only one place. To use them in your own repository, copy `fix.ps1`, `lint.ps1`, and the
corresponding lint configuration files from `templates/lint/` into the root of your repository.

### fix.ps1 — Auto-fix

`fix.ps1` applies all available auto-fixers and always exits 0. Run it after making changes to
automatically handle formatting so that agents and developers do not need to respond to lint output.

It handles:

- **YAML formatting** via `yamlfix` and YAML line-ending normalisation
- **Markdown formatting** via `markdownlint-cli2 --fix`
- **C# formatting** via `dotnet format` (when a `.sln` or `.slnx` file is present)

Running locally:

```powershell
./fix.ps1
```

### lint.ps1 — Lint checks

`lint.ps1` runs all lint checks and reports failures. It exits 1 if any check fails. Use it as the
CI/CD merge gate and during pre-PR cleanup.

It checks:

- **YAML** via `yamllint`
- **Spelling** via `cspell`
- **Markdown** via `markdownlint-cli2`
- **Compliance tools** via `reqstream`, `versionmark`, and `reviewmark`
- **C# formatting** via `dotnet format --verify-no-changes`

In CI/CD:

```yaml
- name: Run linters
  shell: pwsh
  run: ./lint.ps1
```

Running locally:

```powershell
./lint.ps1
```

Both scripts install all required dependencies (npm packages and yamllint via Python venv) before
running their respective operations.
