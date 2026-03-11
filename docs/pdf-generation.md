# PDF Document Generation

Release documentation is published as polished, professionally formatted PDF documents using a
two-stage process: Pandoc converts Markdown to HTML, and Weasyprint renders the HTML to PDF.

This pipeline means that all release documents are:

- **Always accurate** — generated from the same source files that the tools produce
- **Consistently styled** — a shared CSS template applies the same visual style to all documents
- **Archivable** — produced as PDF/A-3u, a format designed for long-term archiving

## Stage 1: Markdown to HTML with Pandoc

[Pandoc](https://pandoc.org/) is a universal document converter that transforms Markdown files into
HTML. In the DEMA Consulting pipeline, Pandoc is invoked via the
[`DemaConsulting.Pandoc`](https://www.nuget.org/packages/DemaConsulting.Pandoc) .NET tool wrapper,
which installs and manages the Pandoc binary.

### Configuration

Each document type has a `definition.yaml` file in its `docs/` subdirectory that defines the Pandoc
conversion options:

```yaml
# docs/guide/definition.yaml
input-files:
  - docs/guide/guide.md
template: docs/template/template.html
css: docs/template/template.css
standalone: true
self-contained: true
metadata:
  title: "User Guide"
  author: "DEMA Consulting"
```

### Invocation

```bash
dotnet pandoc \
  --defaults docs/guide/definition.yaml \
  --filter node_modules/.bin/mermaid-filter \
  --metadata version="${{ inputs.version }}" \
  --metadata date="$(date +'%Y-%m-%d')" \
  --output docs/guide/guide.html
```

The `mermaid-filter` node package renders any Mermaid diagram blocks embedded in the Markdown into
SVG images during the conversion.

## Stage 2: HTML to PDF with Weasyprint

[Weasyprint](https://weasyprint.org/) is a visual HTML/CSS renderer that produces PDF documents. In
the DEMA Consulting pipeline, Weasyprint is invoked via the
[`DemaConsulting.Weasyprint`](https://www.nuget.org/packages/DemaConsulting.Weasyprint) .NET tool
wrapper.

### Invocation

```bash
dotnet weasyprint \
  --pdf-variant pdf/a-3u \
  docs/guide/guide.html \
  "docs/MyProject User Guide.pdf"
```

The `--pdf-variant pdf/a-3u` flag produces a PDF/A-3u file, which is an ISO-standardized archival
format suitable for long-term storage.

## Documents Produced

The following PDF documents are produced for every release:

| Document | Source Markdown | Contents |
| :------- | :-------------- | :------- |
| **Build Notes** | `docs/buildnotes.md` + `docs/buildnotes/versions.md` | Changes, bug fixes, tool versions |
| **User Guide** | `docs/guide/guide.md` | Comprehensive usage documentation |
| **Code Quality** | `docs/quality/codeql-quality.md` + `docs/quality/sonar-quality.md` | CodeQL and SonarCloud analysis |
| **Requirements** | `docs/requirements/requirements.md` | Full requirements list |
| **Requirements Justifications** | `docs/justifications/justifications.md` | Rationale for each requirement |
| **Trace Matrix** | `docs/tracematrix/tracematrix.md` | Requirements-to-tests coverage |
| **Review Plan** | `docs/reviewplan/introduction.md` + `docs/reviewplan/review-plan.md` | Files requiring review and their coverage |
| **Review Report** | `docs/reviewreport/introduction.md` + `docs/reviewreport/review-report.md` | Currency status of each review-set |

## CI/CD Integration

All PDF generation runs in the `build-docs` job, after all test results, quality reports, and
requirements documents have been generated:

```yaml
# Generate HTML with Pandoc
- name: Generate Guide HTML
  run: >
    dotnet pandoc
    --defaults docs/guide/definition.yaml
    --filter node_modules/.bin/mermaid-filter.cmd
    --metadata version="${{ inputs.version }}"
    --metadata date="$(date +'%Y-%m-%d')"
    --output docs/guide/guide.html

# Convert to PDF with Weasyprint
- name: Generate Guide PDF
  run: >
    dotnet weasyprint
    --pdf-variant pdf/a-3u
    docs/guide/guide.html
    "docs/MyProject User Guide.pdf"
```

The resulting PDF files are uploaded as pipeline artifacts and attached to the GitHub Release.
