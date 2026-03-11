# Review Template

This document records the formal review of a set of project files. Complete all sections
below, recording the outcome of each check. Checklist sections that do not apply to the
content under review may be skipped with a justification recorded at the section level.

## Outcomes

Each check must be recorded with one of the following outcomes:

| Outcome | Meaning |
| :------ | :------ |
| Pass | The check was performed and the criterion is satisfied |
| Fail | The check was performed and the criterion is not satisfied |
| N/A | The check does not apply; justification is required |

---

## 1. Introduction

### 1.1 Review Details

| Field | Value |
| :---- | :---- |
| Project | |
| Review ID | |
| Review Title | |
| Fingerprint | |
| Review Date | |

### 1.2 Reviewers

| Name | Role | Organization |
| :--- | :--- | :----------- |
| | | |
| | | |

### 1.3 Files Under Review

| File |
| :--- |
| |

---

## 2. Review Checklist

### 2.1 Requirements Checks

**Applicable:** Yes / No

*Skip this section if the review contains no requirements files. If not applicable,
record the reason here:*

| # | Check | Outcome | Justification |
| :-- | :---- | :------ | :------------ |
| REQ-01 | All requirements have a unique identifier | | |
| REQ-02 | All requirements are clearly and unambiguously stated | | |
| REQ-03 | All requirements are verifiable (can be tested or objectively checked) | | |
| REQ-04 | Requirements conform to the project requirements format | | |
| REQ-05 | Requirements describe what is required, not how to implement it | | |

### 2.2 Documentation Checks

**Applicable:** Yes / No

*Skip this section if the review contains no documentation files. If not applicable,
record the reason here:*

| # | Check | Outcome | Justification |
| :-- | :---- | :------ | :------------ |
| DOC-01 | Documentation is free of technical inaccuracies | | |
| DOC-02 | Documentation is consistent with the current implementation and requirements | | |
| DOC-03 | All referenced external documents and dependencies are correctly identified | | |
| DOC-04 | Documentation is free of spelling and grammar errors | | |

### 2.3 Code Checks

**Applicable:** Yes / No

*Skip this section if the review contains no source code files. If not applicable,
record the reason here:*

| # | Check | Outcome | Justification |
| :-- | :---- | :------ | :------------ |
| CODE-01 | Code conforms to the project coding standards and style guide | | |
| CODE-02 | No obvious security vulnerabilities are present (e.g., injection flaws, hardcoded credentials) | | |
| CODE-03 | Error conditions and unexpected inputs are handled appropriately | | |
| CODE-04 | No obvious resource leaks are present (file handles, connections, memory) | | |
| CODE-05 | No hardcoded values are present that should be configurable | | |
| CODE-06 | No debug artifacts or commented-out code have been left in the codebase | | |

### 2.4 Testing Checks

**Applicable:** Yes / No

*Skip this section if the review contains no test code files. If not applicable,
record the reason here:*

| # | Check | Outcome | Justification |
| :-- | :---- | :------ | :------------ |
| TEST-01 | Tests cover expected (happy-path) behavior | | |
| TEST-02 | Tests cover error conditions and boundary cases | | |
| TEST-03 | Tests are independent and repeatable (no shared mutable state, no ordering dependency) | | |
| TEST-04 | Test names clearly describe the behavior being verified | | |

### 2.5 Requirements–Documentation Checks

**Applicable:** Yes / No

*Skip this section if the review contains no requirements files or no documentation
files. If not applicable, record the reason here:*

| # | Check | Outcome | Justification |
| :-- | :---- | :------ | :------------ |
| REQDOC-01 | All requirements in the review-set are addressed in the documentation | | |
| REQDOC-02 | No requirement is contradicted by the documentation | | |

### 2.6 Requirements–Implementation Checks

**Applicable:** Yes / No

*Skip this section if the review contains no requirements files or no source code
files. If not applicable, record the reason here:*

| # | Check | Outcome | Justification |
| :-- | :---- | :------ | :------------ |
| REQIMP-01 | All requirements in the review-set are addressed by the implementation | | |
| REQIMP-02 | No requirement is contradicted by the implementation | | |

### 2.7 Requirements–Testing Checks

**Applicable:** Yes / No

*Skip this section if the review contains no requirements files or no test code files.
If not applicable, record the reason here:*

| # | Check | Outcome | Justification |
| :-- | :---- | :------ | :------------ |
| REQTEST-01 | Every requirement in the review-set is covered by at least one test | | |
| REQTEST-02 | Tests verify the behavior described in each requirement | | |

### 2.8 Code–Documentation Checks

**Applicable:** Yes / No

*Skip this section if the review-set contains no source code files or no documentation
files. If not applicable, record the reason here:*

| # | Check | Outcome | Justification |
| :-- | :---- | :------ | :------------ |
| CODEDOC-01 | All public APIs and interfaces are documented | | |
| CODEDOC-02 | Non-obvious algorithms and significant design decisions are explained | | |

---

## 3. Conclusion

### 3.1 Summary of Findings

*List any checks recorded as Fail, and any observations that do not constitute a failure
but should be noted for the project record:*

| # | Check | Finding |
| :-- | :---- | :------ |
| | | |

### 3.2 Overall Outcome

**Overall Outcome:** Pass / Fail

*State the basis for the overall outcome, including any conditions or follow-up actions
required before the review-set can be considered approved:*

### 3.3 Reviewer Sign-Off

| Name | Role | Signature | Date |
| :--- | :--- | :-------- | :--- |
| | | | |
| | | | |
