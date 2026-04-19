# File Assertions

[DemaConsulting.FileAssert](https://github.com/demaconsulting/FileAssert) is a .NET CLI tool for
asserting file properties using YAML-defined test suites. It validates files against acceptance
criteria such as existence, size, content, and structured document requirements — making it ideal
for verifying CI/CD pipeline outputs.

## Role in Continuous Compliance

FileAssert fills two roles in the Continuous Compliance pipeline:

1. **OTS Evidence** — assertions on outputs produced by third-party tools (Pandoc, WeasyPrint, or
   any other tool) prove that those tools are functional in the target environment. These assertions
   run *before* ReqStream generates the requirements documents, so the test results are available as
   evidence when the trace matrix is assembled.

2. **Output Validation** — assertions on all pipeline outputs (including the requirements and trace
   matrix documents) confirm that each artifact was generated correctly, has the right content, and
   meets structural requirements.

## What FileAssert Can Check

FileAssert supports a wide range of assertion types that apply to any file the pipeline produces:

| File Type | What Can Be Checked |
| :-------- | :------------------ |
| **Any file** | Existence (count, min, max), size (min-size, max-size) |
| **Text files** | Contains string, does not contain string, matches regex, does not match regex |
| **PDF documents** | Metadata fields (Title, Author, Subject, Keywords), page count, body text |
| **HTML documents** | XPath node queries with count, min, or max |
| **XML documents** | XPath node queries with count, min, or max |
| **YAML documents** | Dot-notation path queries with count, min, or max |
| **JSON documents** | Dot-notation path queries with count, min, or max |

This makes FileAssert applicable well beyond PDF validation — it can check build outputs,
configuration artifacts, test result files, generated reports, and any other structured file
the pipeline produces.

## Configuration

FileAssert reads a `.fileassert.yaml` file at the repository root. Tests are grouped using **tags**
so they can be run in stages — for example, once per document group in the PDF pipeline:

```yaml
# .fileassert.yaml
tests:

  # --- File existence and size ---

  - name: MyProject_ArtifactsExist
    tags: [smoke]
    files:
      - pattern: "artifacts/*.nupkg"
        count: 1
        min-size: 1024

  # --- Text file content ---

  - name: MyProject_ChangelogValid
    tags: [smoke]
    files:
      - pattern: "CHANGELOG.md"
        count: 1
        text:
          - contains: "## "
          - does-not-contain: "TODO"

  # --- JSON config/artifact ---

  - name: MyProject_VersionCaptureValid
    tags: [smoke]
    files:
      - pattern: "artifacts/versionmark-*.json"
        min: 1
        json:
          - query: "tools"
            min: 1

  # --- YAML config/artifact ---

  - name: MyProject_RequirementsValid
    tags: [smoke]
    files:
      - pattern: "requirements.yaml"
        count: 1
        yaml:
          - query: "sections"
            min: 1

  # --- XML (e.g. TRX test results) ---

  - name: MyProject_TestResultsValid
    tags: [smoke]
    files:
      - pattern: "artifacts/*.trx"
        min: 1
        xml:
          - query: "//*[local-name()='UnitTestResult']"
            min: 1

  # --- HTML (e.g. Pandoc intermediate output) ---

  - name: Pandoc_UserGuideHtml
    tags: [user-guide]
    files:
      - pattern: "docs/user_guide/user_guide.html"
        count: 1
        html:
          - query: "//head/title"
            count: 1
        text:
          - contains: "User Guide"

  # --- PDF (e.g. WeasyPrint output) ---

  - name: WeasyPrint_UserGuidePdf
    tags: [user-guide]
    files:
      - pattern: "docs/MyProject User Guide.pdf"
        count: 1
        pdf:
          metadata:
            - field: "Title"
              contains: "User Guide"
            - field: "Author"
              contains: "DEMA Consulting"
            - field: "Subject"
              contains: "User Guide"
          pages:
            min: 3
          text:
            - contains: "User Guide"
```

## Invocation

FileAssert is invoked with a test name or tag to run only a targeted subset of tests. Pass
`--results` to write a TRX or JUnit file that ReqStream can consume as test evidence:

```bash
# Run tests matching a tag
dotnet fileassert --tag build-notes --results artifacts/fileassert-build-notes.trx

# Run tests matching a name
dotnet fileassert MyProject_ArtifactsExist --results artifacts/fileassert-smoke.trx

# Run all tests
dotnet fileassert --results artifacts/fileassert-all.trx
```

## Acceptance Criteria Reference

| Criterion | Description |
| :-------- | :---------- |
| `count` | Exact number of files matching the glob pattern |
| `min` | Minimum number of files matching the glob pattern |
| `max` | Maximum number of files matching the glob pattern |
| `min-size` | Minimum file size in bytes |
| `max-size` | Maximum file size in bytes |
| `text[].contains` | File text must contain the specified string |
| `text[].does-not-contain` | File text must not contain the specified string |
| `text[].matches` | File text must match the specified regular expression |
| `text[].does-not-contain-regex` | File text must not match the specified regular expression |
| `pdf.metadata[].field` + `contains` | PDF metadata field must contain the specified text |
| `pdf.metadata[].field` + `matches` | PDF metadata field must match the regular expression |
| `pdf.pages.min` / `pdf.pages.max` | PDF page count bounds |
| `pdf.text[].contains` | PDF body text must contain the specified text |
| `html[].query` + `count`/`min`/`max` | XPath node selection with count assertions |
| `xml[].query` + `count`/`min`/`max` | XPath node selection with count assertions |
| `yaml[].query` + `count`/`min`/`max` | Dot-notation path with count assertions |
| `json[].query` + `count`/`min`/`max` | Dot-notation path with count assertions |

## PDF Metadata Assertions

When validating generated PDF documents, metadata fields map directly to the document's `title.txt`
Pandoc front matter:

| PDF Metadata Field | Source in `title.txt` | Example Assertion |
| :----------------- | :-------------------- | :---------------- |
| `Title` | `title:` | `contains: "MyProject User Guide"` |
| `Author` | `author:` | `contains: "DEMA Consulting"` |
| `Subject` | `description:` | `contains: "User Guide"` |
| `Keywords` | `keywords:` list | `contains: "User Guide"` |

> **Note:** The `subtitle:` field in `title.txt` appears only on the visual cover page — it does
> **not** map to any PDF metadata field. All `Subject` assertions must match the `description:`
> field.

## OTS Evidence Timing

In the PDF generation pipeline, FileAssert tests for each document group (build-notes, code-quality,
code-review, design, user-guide) run *before* ReqStream generates the requirements and trace matrix
documents. This is intentional: ReqStream consumes TRX files matching `artifacts/**/*.trx`, so the
individual `fileassert-*.trx` result files are available as test evidence when ReqStream runs.

Tests for the requirements documents themselves (tagged `requirements`) run *after* ReqStream
completes. They validate those final documents are well-formed but do not contribute to OTS
requirements evidence.

## Self-Validation

FileAssert includes built-in self-validation tests that verify its assertion engine is functional:

```bash
dotnet fileassert --validate --results artifacts/fileassert-self-validation.trx
```

Run self-validation after the document-group assertions and before ReqStream, so the result is
available as evidence for FileAssert's own requirements.

## CI/CD Integration

A complete document-generation job interleaves FileAssert assertions with document production:

```yaml
# Generate and assert the Build Notes group
- name: Generate Build Notes HTML with Pandoc
  shell: bash
  run: >
    dotnet pandoc
    --defaults docs/build_notes/definition.yaml
    --metadata version="${{ inputs.version }}"
    --output docs/build_notes/build_notes.html

- name: Generate Build Notes PDF with WeasyPrint
  shell: bash
  run: >
    dotnet weasyprint --pdf-variant pdf/a-3u
    docs/build_notes/build_notes.html
    "docs/MyProject Build Notes.pdf"

- name: Assert Build Notes Documents with FileAssert
  shell: bash
  run: >
    dotnet fileassert
    --tag build-notes
    --results artifacts/fileassert-build-notes.trx

# ... repeat for code-quality, code-review, design, user-guide ...

# FileAssert self-validation — after all OTS document groups are done
- name: Run FileAssert self-validation
  shell: bash
  run: >
    dotnet fileassert
    --validate
    --results artifacts/fileassert-self-validation.trx

# Requirements and trace matrix — after all OTS evidence is in place
- name: Run ReqStream
  shell: bash
  run: >
    dotnet reqstream
    --requirements requirements.yaml
    --tests "artifacts/**/*.trx"
    --enforce

# Validate requirements documents — these run after ReqStream
- name: Assert Requirements Documents with FileAssert
  shell: bash
  run: >
    dotnet fileassert
    --tag requirements
    --results artifacts/fileassert-requirements.trx
```

See [PDF Document Generation](pdf-generation.md) for the full Pandoc and WeasyPrint pipeline that
produces the documents FileAssert validates.
