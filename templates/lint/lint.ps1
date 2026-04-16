# lint.ps1
#
# PURPOSE:
#   Unified cross-platform linting script (replaces lint.bat and lint.sh).
#
#   -FixOnly mode: Applies all available auto-fixers silently. Always exits 0.
#                  Run this after making changes (agent workflow).
#                  Handles most formatting issues automatically so the agent
#                  does not need to respond to lint output at all.
#
#   Default mode:  Runs all lint checks and reports failures. Exits 1 on error.
#                  Used by CI/CD as the merge gate and by the lint-fix agent
#                  during pre-PR cleanup.
#
# EXTENSION POINTS:
#   Search for "[PROJECT-SPECIFIC]" comments to find the designated locations
#   for adding project-specific linting and auto-fix operations.
#
# MODIFICATION POLICY:
#   Only modify this file to add project-specific operations at the designated
#   [PROJECT-SPECIFIC] extension points, or to update tool versions as needed.

param(
    [switch]$FixOnly
)

# ==============================================================================
# AUTO-FIX MODE
# Applies all auto-fixers silently. Never fails — applies what it can and
# exits 0 so agents do not react to any output as a problem to solve.
# ==============================================================================

if ($FixOnly) {

    # --- .NET Auto-Format ---
    # Formats C# code to match .editorconfig rules.
    $slnFiles = @(Get-ChildItem -Filter "*.sln" -ErrorAction SilentlyContinue) +
                @(Get-ChildItem -Filter "*.slnx" -ErrorAction SilentlyContinue)
    if ($slnFiles.Count -gt 0) {
        dotnet format 2>$null
    }

    # [PROJECT-SPECIFIC] Add additional language-specific auto-formatters here.
    # Example (C/C++ with clang-format):
    #   Get-ChildItem -Recurse -Include "*.cpp","*.hpp","*.h" |
    #       ForEach-Object { clang-format -i $_.FullName } 2>$null

    # --- Markdown Auto-Fix ---
    # Fixes markdownlint-detectable formatting issues automatically.
    $env:PUPPETEER_SKIP_DOWNLOAD = "true"
    npm install --silent 2>$null
    if ($LASTEXITCODE -eq 0) {
        npx markdownlint-cli2 --fix "**/*.md" 2>$null
    }

    # --- YAML Auto-Fix ---
    # Fixes common YAML formatting issues automatically.
    if (-not (Test-Path ".venv")) {
        python -m venv .venv 2>$null
    }
    $activateScript = if (Test-Path ".venv/Scripts/Activate.ps1") {
        ".venv/Scripts/Activate.ps1"    # Windows
    } else {
        ".venv/bin/Activate.ps1"        # Linux/macOS
    }
    if (Test-Path $activateScript) {
        & $activateScript 2>$null
        if (Get-Command deactivate -ErrorAction SilentlyContinue) {
            pip install -r pip-requirements.txt --quiet --disable-pip-version-check 2>$null
            yamlfix . 2>$null
            deactivate 2>$null
        }
    }

    # [PROJECT-SPECIFIC] Add additional auto-fixers here.
    # Example (Prettier for TypeScript/JSON):
    #   npx prettier --write "src/**/*.{ts,json}" 2>$null

    # Auto-fix mode always exits 0.
    exit 0
}

# ==============================================================================
# CHECK MODE (default)
# Runs all lint checks. Exits 1 if any check fails.
# ==============================================================================

$lintError = $false

# --- PYTHON SECTION ---
# Sets up a virtual environment and runs yamllint.

$skipPython = $false
if (-not (Test-Path ".venv")) {
    python -m venv .venv
    if ($LASTEXITCODE -ne 0) { $lintError = $true; $skipPython = $true }
}

if (-not $skipPython) {
    $activateScript = if (Test-Path ".venv/Scripts/Activate.ps1") {
        ".venv/Scripts/Activate.ps1"    # Windows
    } else {
        ".venv/bin/Activate.ps1"        # Linux/macOS
    }
    if (Test-Path $activateScript) {
        & $activateScript
        if ($LASTEXITCODE -ne 0) { $lintError = $true; $skipPython = $true }
    } else {
        $lintError = $true; $skipPython = $true
    }
}

if (-not $skipPython) {
    pip install -r pip-requirements.txt --quiet --disable-pip-version-check
    if ($LASTEXITCODE -ne 0) { $lintError = $true; $skipPython = $true }
}

if (-not $skipPython) {
    yamllint .
    if ($LASTEXITCODE -ne 0) { $lintError = $true }
    deactivate
}

# [PROJECT-SPECIFIC]Add additional Python-based lint checks here.
# Example:
#   if (-not $skipPython) {
#       flake8 src/
#       if ($LASTEXITCODE -ne 0) { $lintError = $true }
#   }

# --- NPM SECTION ---
# Installs npm dependencies and runs cspell and markdownlint-cli2.

$skipNpm = $false
$env:PUPPETEER_SKIP_DOWNLOAD = "true"
npm install --silent
if ($LASTEXITCODE -ne 0) { $lintError = $true; $skipNpm = $true }

if (-not $skipNpm) {
    npx cspell --no-progress --no-color --quiet "**/*.{md,yaml,yml,json,cs,cpp,hpp,h,txt}"
    if ($LASTEXITCODE -ne 0) { $lintError = $true }

    npx markdownlint-cli2 "**/*.md"
    if ($LASTEXITCODE -ne 0) { $lintError = $true }
}

# [PROJECT-SPECIFIC] Add additional npm-based lint checks here.
# Example (ESLint for TypeScript):
#   if (-not $skipNpm) {
#       npx eslint "src/**/*.ts"
#       if ($LASTEXITCODE -ne 0) { $lintError = $true }
#   }

# --- DOTNET LINTING SECTION ---
# Runs compliance tools: reqstream, versionmark, reviewmark.

$skipDotnetTools = $false
dotnet tool restore > $null
if ($LASTEXITCODE -ne 0) { $lintError = $true; $skipDotnetTools = $true }

if (-not $skipDotnetTools) {
    dotnet reqstream --lint --requirements requirements.yaml
    if ($LASTEXITCODE -ne 0) { $lintError = $true }

    dotnet versionmark --lint
    if ($LASTEXITCODE -ne 0) { $lintError = $true }

    dotnet reviewmark --lint
    if ($LASTEXITCODE -ne 0) { $lintError = $true }
}

# [PROJECT-SPECIFIC] Add additional dotnet tool lint checks here.
# Example:
#   if (-not $skipDotnetTools) {
#       dotnet custom-tool --lint
#       if ($LASTEXITCODE -ne 0) { $lintError = $true }
#   }

# --- DOTNET FORMATTING SECTION ---
# Verifies C# code formatting matches .editorconfig rules.

$skipDotnetFormat = $false
dotnet restore > $null
if ($LASTEXITCODE -ne 0) { $lintError = $true; $skipDotnetFormat = $true }

if (-not $skipDotnetFormat) {
    dotnet format --verify-no-changes --no-restore
    if ($LASTEXITCODE -ne 0) { $lintError = $true }
}

# [PROJECT-SPECIFIC] Add additional format verification checks here.
# Example (clang-format check for C/C++):
#   Get-ChildItem -Recurse -Include "*.cpp","*.hpp","*.h" | ForEach-Object {
#       $result = clang-format --dry-run --Werror $_.FullName 2>&1
#       if ($LASTEXITCODE -ne 0) { Write-Output $result; $lintError = $true }
#   }

exit ($lintError ? 1 : 0)
