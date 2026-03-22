# Environment Setup

This guide describes how to set up a local development environment for working with the Continuous
Compliance toolchain. The same toolchain runs in CI/CD, so a correctly configured local environment
lets you catch linting and compliance failures before pushing to the remote.

## Prerequisites

The following tools must be installed before setting up a Continuous Compliance project:

| Tool | Purpose | Install |
| :--- | :------ | :------ |
| [.NET SDK](https://dotnet.microsoft.com/download) (8 or later) | Runs all DEMA Consulting .NET tools | dotnet.microsoft.com |
| [Node.js](https://nodejs.org/) (18 or later) | Runs markdownlint-cli2, cspell, and mermaid-filter | nodejs.org |
| [Python](https://www.python.org/) (3.11 or later) | Runs yamllint via a virtual environment | python.org |
| [Git](https://git-scm.com/) | Source control and build-notes history access | git-scm.com |

Check that each tool is available in your shell after installation:

```bash
dotnet --version
node --version
python --version
git --version
```

## Linting Setup

Linting dependencies are installed via the lint scripts bundled in every Continuous Compliance
project. Copy the lint scripts and their configuration files from `templates/lint/` (or from a
reference project) into your repository root, then run the appropriate script for your platform:

**Linux / macOS:**

```bash
bash ./lint.sh
```

**Windows:**

```bat
lint.bat
```

The script will:

1. Create a Python virtual environment (`.venv/`) and install `yamllint` from `pip-requirements.txt`
2. Install npm packages (`cspell`, `markdownlint-cli2`) via `npm install`
3. Run all three linters against the repository

On subsequent runs the virtual environment and `node_modules/` directory are reused, so only the
linting step itself is repeated.

## .NET Tool Setup

The DEMA Consulting tools (VersionMark, SonarMark, SarifMark, ReqStream, ReviewMark, BuildMark,
Pandoc, Weasyprint) are distributed as .NET local tools and declared in `.config/dotnet-tools.json`.
Install them with:

```bash
dotnet tool restore
```

Run this command once after cloning the repository, and again whenever `.config/dotnet-tools.json`
is updated.

## Verifying the Setup

After installing all dependencies, run tool self-validation to confirm everything is working:

```bash
dotnet versionmark --validate --results test-results/versionmark-check.trx
dotnet reqstream --validate --results test-results/reqstream-check.trx
dotnet reviewmark --validate --results test-results/reviewmark-check.trx
```

Each command prints a summary and exits with code 0 if all built-in tests pass.

## Mermaid Filter

The PDF generation pipeline uses [mermaid-filter](https://github.com/raghur/mermaid-filter) to
render Mermaid diagram blocks embedded in Markdown. It is installed as an npm devDependency alongside
the linting tools and requires a Chromium-compatible browser. On most systems this is satisfied by
installing Google Chrome or Chromium.

On Linux CI environments without a display, a system installation of Google Chrome or Chromium is
required for Puppeteer to run in headless mode.

## Troubleshooting

See [Troubleshooting](troubleshooting.md) for solutions to common setup problems.
