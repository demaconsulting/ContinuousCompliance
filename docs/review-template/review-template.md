# _[Review Title]_

## 1. Introduction

### 1.1 Purpose

This document records the formal review of a set of project files.

### 1.2 Scope

_[Describe the scope of this review, including which project, release, or change is being reviewed.]_

### 1.3 Outcomes

Each check must be recorded with one of the following outcomes:

| Outcome | Meaning |
| :------ | :------ |
| Pass | The check was performed and the criterion is satisfied |
| Fail | The check was performed and the criterion is not satisfied |
| N/A | The check does not apply; justification is required |

### 1.4 Review Details

| Field | Value |
| :---- | :---- |
| Project | _[Project name]_ |
| Review ID | _[Review identifier]_ |
| Review Title | _[Review title]_ |
| Fingerprint | _[Fingerprint of the complete file set]_ |
| Review Date | _[YYYY-MM-DD]_ |

### 1.5 Reviewers

| Name | Role | Organization | Signature | Date |
| :--- | :--- | :----------- | :-------- | :--- |
| _[Reviewer name]_ | _[Role]_ | _[Organization]_ | _[Signature]_ | _[YYYY-MM-DD]_ |
| _[Reviewer name]_ | _[Role]_ | _[Organization]_ | _[Signature]_ | _[YYYY-MM-DD]_ |

### 1.6 Files Under Review

| File |
| :--- |
| _[filename]_ |

---

## 2. Review Checklist

### 2.1 Requirements Checks

**Applicable:** Yes / No

*Skip this section if the review contains no requirements files. If not applicable,
record the reason here:*

| # | Check | Outcome | Justification |
| :-- | :---- | :------ | :------------ |
| REQ-01 | All requirements have a unique identifier | Pass / Fail / N/A | _Required if Fail or N/A_ |
| REQ-02 | All requirements are unambiguous (only one valid interpretation) | Pass / Fail / N/A | _Required if Fail or N/A_ |
| REQ-03 | All requirements are testable (compliance can be demonstrated by a test) | Pass / Fail / N/A | _Required if Fail or N/A_ |
| REQ-04 | All requirements are consistent (no requirement contradicts another) | Pass / Fail / N/A | _Required if Fail or N/A_ |
| REQ-05 | All requirements are complete (no TBDs, undefined terms, or missing information) | Pass / Fail / N/A | _Required if Fail or N/A_ |
| REQ-06 | All requirements are verifiable (can be objectively confirmed as met or not met) | Pass / Fail / N/A | _Required if Fail or N/A_ |

### 2.2 Documentation Checks

**Applicable:** Yes / No

*Skip this section if the review contains no documentation files. If not applicable,
record the reason here:*

| # | Check | Outcome | Justification |
| :-- | :---- | :------ | :------------ |
| DOC-01 | Documentation is free of technical inaccuracies | Pass / Fail / N/A | _Required if Fail or N/A_ |
| DOC-02 | Documentation is consistent with the current implementation and requirements | Pass / Fail / N/A | _Required if Fail or N/A_ |
| DOC-03 | All referenced external documents and dependencies are correctly identified | Pass / Fail / N/A | _Required if Fail or N/A_ |
| DOC-04 | Documentation is free of spelling and grammar errors | Pass / Fail / N/A | _Required if Fail or N/A_ |

### 2.3 Code Checks

**Applicable:** Yes / No

*Skip this section if the review contains no source code files. If not applicable,
record the reason here:*

| # | Check | Outcome | Justification |
| :-- | :---- | :------ | :------------ |
| CODE-01 | Code conforms to the project coding standards and style guide | Pass / Fail / N/A | _Required if Fail or N/A_ |
| CODE-02 | No obvious security vulnerabilities are present (e.g., injection flaws, hardcoded credentials) | Pass / Fail / N/A | _Required if Fail or N/A_ |
| CODE-03 | Error conditions and unexpected inputs are handled appropriately | Pass / Fail / N/A | _Required if Fail or N/A_ |
| CODE-04 | No obvious resource leaks are present (file handles, connections, memory) | Pass / Fail / N/A | _Required if Fail or N/A_ |
| CODE-05 | No hardcoded values are present that should be configurable | Pass / Fail / N/A | _Required if Fail or N/A_ |
| CODE-06 | No debug artifacts or commented-out code have been left in the codebase | Pass / Fail / N/A | _Required if Fail or N/A_ |

### 2.4 Testing Checks

**Applicable:** Yes / No

*Skip this section if the review contains no test code files. If not applicable,
record the reason here:*

| # | Check | Outcome | Justification |
| :-- | :---- | :------ | :------------ |
| TEST-01 | Tests cover expected (happy-path) behavior | Pass / Fail / N/A | _Required if Fail or N/A_ |
| TEST-02 | Tests cover error conditions and boundary cases | Pass / Fail / N/A | _Required if Fail or N/A_ |
| TEST-03 | Tests are independent and repeatable (no shared mutable state, no ordering dependency) | Pass / Fail / N/A | _Required if Fail or N/A_ |
| TEST-04 | Test names clearly describe the behavior being verified | Pass / Fail / N/A | _Required if Fail or N/A_ |

### 2.5 Requirements vs Documentation Checks

**Applicable:** Yes / No

*Skip this section if the review contains no requirements files or no documentation
files. If not applicable, record the reason here:*

| # | Check | Outcome | Justification |
| :-- | :---- | :------ | :------------ |
| REQDOC-01 | All requirements under review are addressed in the documentation | Pass / Fail / N/A | _Required if Fail or N/A_ |
| REQDOC-02 | No requirement is contradicted by the documentation | Pass / Fail / N/A | _Required if Fail or N/A_ |

### 2.6 Requirements vs Implementation Checks

**Applicable:** Yes / No

*Skip this section if the review contains no requirements files or no source code
files. If not applicable, record the reason here:*

| # | Check | Outcome | Justification |
| :-- | :---- | :------ | :------------ |
| REQIMP-01 | All requirements under review are addressed by the implementation | Pass / Fail / N/A | _Required if Fail or N/A_ |
| REQIMP-02 | No requirement is contradicted by the implementation | Pass / Fail / N/A | _Required if Fail or N/A_ |

### 2.7 Requirements vs Testing Checks

**Applicable:** Yes / No

*Skip this section if the review contains no requirements files or no test code files.
If not applicable, record the reason here:*

| # | Check | Outcome | Justification |
| :-- | :---- | :------ | :------------ |
| REQTEST-01 | Every requirement under review is covered by at least one test | Pass / Fail / N/A | _Required if Fail or N/A_ |
| REQTEST-02 | Tests verify the behavior described in each requirement | Pass / Fail / N/A | _Required if Fail or N/A_ |

### 2.8 Code vs Documentation Checks

**Applicable:** Yes / No

*Skip this section if the review contains no source code files or no documentation
files. If not applicable, record the reason here:*

| # | Check | Outcome | Justification |
| :-- | :---- | :------ | :------------ |
| CODEDOC-01 | All public APIs and interfaces are documented | Pass / Fail / N/A | _Required if Fail or N/A_ |
| CODEDOC-02 | Non-obvious algorithms and significant design decisions are explained | Pass / Fail / N/A | _Required if Fail or N/A_ |

---

## 3. Conclusion

### 3.1 Summary of Findings

*List any checks recorded as Fail, and any observations that do not constitute a failure
but should be noted for the project record:*

| # | Check | Finding |
| :-- | :---- | :------ |
| _[check ID]_ | _[check description]_ | _[describe the finding]_ |

### 3.2 Overall Outcome

**Overall Outcome:** Pass / Fail

*State the basis for the overall outcome, including any conditions or follow-up actions
required before the review can be considered approved:*
