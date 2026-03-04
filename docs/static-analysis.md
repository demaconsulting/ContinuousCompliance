# Static Analysis

Static analysis catches code quality and security issues before they reach production. DEMA Consulting
projects use two complementary analysis approaches — SonarQube/SonarCloud for continuous quality metrics,
and CodeQL for deep security and correctness analysis — producing a combined code quality report with
every release.

## SonarQube / SonarCloud

[DemaConsulting.SonarMark](https://github.com/demaconsulting/SonarMark) generates markdown reports from
SonarQube or SonarCloud analysis results. It fetches quality gate status, issues, and security hot-spots
directly from the SonarQube/SonarCloud REST API.

### How It Works

SonarScanner is run as part of the standard build job, wrapping the dotnet build and test steps:

```bash
# Start analysis
dotnet dotnet-sonarscanner begin \
  /k:"my-org_my-project" \
  /o:"my-org" \
  /d:sonar.token="$SONAR_TOKEN" \
  /d:sonar.host.url="https://sonarcloud.io" \
  /d:sonar.cs.opencover.reportsPaths=**/*.opencover.xml \
  /d:sonar.scanner.scanAll=false

# Build and test (with coverage)
dotnet build --configuration Release
dotnet test --collect "XPlat Code Coverage;Format=opencover"

# End analysis and upload results to SonarCloud
dotnet dotnet-sonarscanner end /d:sonar.token="$SONAR_TOKEN"
```

After the analysis is uploaded, SonarMark retrieves the results and generates a markdown report:

```bash
dotnet sonarmark \
  --server https://sonarcloud.io \
  --project-key my-org_my-project \
  --branch main \
  --token "$SONAR_TOKEN" \
  --report docs/quality/sonar-quality.md \
  --report-depth 1
```

### Enforcement

The `--enforce` flag causes the pipeline to fail if the SonarQube quality gate is not passed:

```bash
dotnet sonarmark \
  --server https://sonarcloud.io \
  --project-key my-org_my-project \
  --token "$SONAR_TOKEN" \
  --enforce
```

### Self-Validation

SonarMark includes built-in self-validation tests that verify its functionality using mock data without
requiring a live SonarQube server:

```bash
dotnet sonarmark --validate --results artifacts/sonarmark-self-validation.trx
```

## CodeQL

[DemaConsulting.SarifMark](https://github.com/demaconsulting/SarifMark) processes SARIF (Static Analysis
Results Interchange Format) files produced by CodeQL and converts them into human-readable markdown reports.

### How It Works

CodeQL analysis runs as a dedicated pipeline job, separate from the main build:

```yaml
- name: Initialize CodeQL
  uses: github/codeql-action/init@v4
  with:
    languages: csharp
    queries: security-and-quality

- name: Build
  run: dotnet build --configuration Release

- name: Perform CodeQL Analysis
  uses: github/codeql-action/analyze@v4
  with:
    output: artifacts
    upload: false
```

The SARIF output is then processed by SarifMark in the document generation job:

```bash
dotnet sarifmark \
  --sarif artifacts/csharp.sarif \
  --report docs/quality/codeql-quality.md \
  --heading "My Project CodeQL Analysis" \
  --report-depth 1
```

### Enforcement

The `--enforce` flag causes the pipeline to fail if any issues are found in the SARIF output:

```bash
dotnet sarifmark \
  --sarif artifacts/csharp.sarif \
  --enforce
```

### Self-Validation

SarifMark includes built-in self-validation tests using mock SARIF data:

```bash
dotnet sarifmark --validate --results artifacts/sarifmark-self-validation.trx
```

## Combined Code Quality Report

The SonarMark and SarifMark outputs are combined using Pandoc into a single Code Quality PDF document
published with every release. See [PDF Document Generation](pdf-generation.md) for details.
