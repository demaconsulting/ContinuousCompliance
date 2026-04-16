# Troubleshooting

This document covers common problems encountered when setting up or running the Continuous Compliance
toolchain, and their solutions.

## Linting

### markdownlint-cli2 fails with "Cannot find module"

**Symptom:** Running `lint.ps1` produces an error such as:

```text
Error: Cannot find module 'markdownlint-cli2'
```

**Cause:** The npm packages have not been installed.

**Solution:** Run `npm install` in the directory containing `package.json`, or re-run the lint
script — it installs npm packages automatically before linting.

---

### cspell flags a valid technical term as misspelled

**Symptom:** cspell reports a word as misspelled that is a genuine tool name, identifier, or
technical term.

**Cause:** The word is not in the project word list.

**Solution:** Do **not** add the word to `.cspell.yaml` without a review. Instead:

1. Confirm the word is spelled correctly.
2. Add the word to the `words` list in `.cspell.yaml` as part of the pull request that introduces
   the technical term, or open a separate proposal (issue or pull request) if the term is being
   added independently.
3. Ensure the change is discussed and reviewed before merging — the word list update may be
   included in the same PR as the code change as long as reviewers can verify the term is genuine.

See the [word list policy](linting.md#word-list-policy) for details.

---

### yamllint fails with "wrong indentation"

**Symptom:** yamllint reports indentation errors in a YAML file that looks correctly indented.

**Cause:** The file uses tabs instead of spaces, or inconsistent indentation widths.

**Solution:** Convert all indentation to 2-space soft tabs. Many editors can be configured in
their settings to enforce this; teams may also add an `.editorconfig` file to standardize
indentation. Check that your editor is not inserting tab characters in YAML files.

---

### Lint script fails with "python: command not found"

**Symptom:** The lint script fails because Python is not found.

**Cause:** Python is not installed or is not on the `PATH`.

**Solution:** Install Python 3.11 or later and ensure the `python` (or `python3`) command is
available in the shell used to run the script. On some systems you may need to create a `python`
alias pointing to `python3`.

---

## .NET Tools

### "dotnet tool restore" fails with "No manifest file found"

**Symptom:**

```text
Cannot find a manifest file; for a list of locations searched, specify the "-d" diagnostic switch.
```

**Cause:** The `.config/dotnet-tools.json` manifest is missing from the repository root or was
not copied from the template.

**Solution:** Copy `.config/dotnet-tools.json` from
[`templates/reqstream/`](https://github.com/demaconsulting/ContinuousCompliance/tree/main/templates/reqstream)
or create it manually, then run `dotnet tool restore` again.

---

### Tool command not found after "dotnet tool restore"

**Symptom:** Running `dotnet versionmark` (or another tool) produces:

```text
No executable found matching command "dotnet-versionmark"
```

**Cause:** The tool restore did not complete successfully, or the tool is being invoked from a
directory that does not have the manifest on its search path.

**Solution:**

1. Run `dotnet tool restore` in the repository root and check for errors.
2. Confirm that `.config/dotnet-tools.json` lists the tool.
3. Run the tool command from the repository root (local tools are not available from subdirectories
   unless `dotnet tool restore` is run there as well).

---

## Requirements Enforcement

### ReqStream reports "Only N of M requirements are satisfied"

**Symptom:**

```text
Error: Only 14 of 16 requirements are satisfied with tests.
```

**Cause:** One or more requirements are not linked to any passing test.

**Solution:**

1. Run ReqStream without `--enforce` to generate the trace matrix.
2. Open the trace matrix (`docs/requirements_report/trace_matrix.md`) and identify the unsatisfied
   requirements (those with no tests or a ❌ status).
3. For each unsatisfied requirement, either:
   - Add a test that covers it and link the test name in the `tests` field, or
   - Remove the requirement if it is no longer applicable.

---

### ReqStream cannot find test result files

**Symptom:**

```text
Warning: No test results found matching "artifacts/**/*.trx"
```

**Cause:** The glob pattern does not match the location or naming of the test result files.

**Solution:**

1. Confirm that the test run produces `.trx` files and that they are saved to the `artifacts/`
   directory (or whichever directory the glob targets).
2. Update the glob pattern in the ReqStream invocation to match the actual file location.
3. If tests are run on multiple platforms, confirm that all result files are downloaded before
   ReqStream runs.

---

## File Reviews

### ReviewMark reports a review as "Stale"

**Symptom:** The review report shows a review-set with status **Stale**.

**Cause:** One or more files in the review-set have changed since the review evidence was produced.
The stored fingerprint no longer matches the current file content.

**Solution:**

1. Re-conduct the review for the affected review-set.
2. Produce a new review evidence PDF and store it in the evidence store.
3. Update the review entry (date and evidence reference) in `.reviewmark.yaml`.
4. Run ReviewMark to confirm the review is now **Current**.

---

### ReviewMark reports a file as "Missing" from coverage

**Symptom:** The review plan shows one or more files that are not covered by any review-set.

**Cause:** A file matching the `needs-review` pattern was added to the repository after the
review-sets were last updated.

**Solution:**

1. Identify the uncovered file(s) in the review plan.
2. Add the file to an appropriate review-set in `.reviewmark.yaml` (or create a new review-set).
3. Conduct a review for the affected review-set and store the evidence.

---

## PDF Generation

### Pandoc fails with "Cannot find filter mermaid-filter"

**Symptom:**

```text
Error running filter node_modules/.bin/mermaid-filter
```

**Cause:** The `mermaid-filter` npm package is not installed.

**Solution:** Check that `mermaid-filter` is listed as a devDependency in your project's
`package.json`, then run `npm install` in the repository root.

On **Windows**, pandoc cannot invoke the bare `mermaid-filter` binary directly. Use the `.cmd`
wrapper instead:

```text
--filter node_modules/.bin/mermaid-filter.cmd
```

See the CI/CD example in [PDF Generation](pdf-generation.md) for the correct Windows invocation.

---

### Weasyprint produces blank or truncated PDFs

**Symptom:** The generated PDF is blank, cut off, or missing content.

**Cause:** Common causes include missing fonts, CSS incompatibility, or an HTML file that references
external resources unavailable at render time.

**Solution:**

1. Open the intermediate HTML file (e.g., `docs/guide/guide.html`) in a browser and confirm it
   renders correctly.
2. Check that all CSS and image paths referenced in the HTML are relative and available alongside
   the HTML file.
3. If the pipeline uses `self-contained: true` in the Pandoc definition, ensure Pandoc is producing
   self-contained HTML before Weasyprint processes it.
4. On headless Linux environments, ensure a Chromium-compatible browser is installed for
   `mermaid-filter`.

---

### PDF/A-3u validation fails

**Symptom:** A downstream PDF/A validator reports that the generated file is not valid PDF/A-3u.

**Cause:** The `--pdf-variant pdf/a-3u` flag was not passed to Weasyprint, or the HTML contains
content that cannot be represented in PDF/A (e.g., JavaScript, external links to non-embedded
resources).

**Solution:**

1. Confirm the Weasyprint invocation includes `--pdf-variant pdf/a-3u`.
2. Remove any JavaScript from the HTML template.
3. Ensure all fonts and images are embedded (use `self-contained: true` in Pandoc or embed assets
   directly in the CSS).

---

## CI/CD

### Pipeline fails with "GH_TOKEN not set"

**Symptom:** BuildMark fails with a GitHub API authentication error.

**Cause:** The `GH_TOKEN` environment variable is not set in the pipeline job.

**Solution:** Add the following to the CI/CD step:

```yaml
env:
  GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

The `GITHUB_TOKEN` secret is provided automatically by GitHub Actions for all repository workflows.

---

### VersionMark reports different tool versions across jobs

**Symptom:** The published versions report shows two different versions of the same tool (e.g.,
the .NET SDK) across build jobs.

**Cause:** The CI/CD matrix uses different runner images or tool installation steps for different
jobs.

**Solution:**

1. Pin the tool version explicitly in the CI/CD workflow (e.g., use a specific `dotnet-version`
   in `actions/setup-dotnet`).
2. Ensure all build jobs use the same runner image version.
3. If cross-platform version differences are intentional (e.g., testing on multiple OS versions),
   document the expected differences in the build notes.
