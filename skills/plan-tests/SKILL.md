---
name: plan-tests
description: "Create a test plan for an approved spec. Use after spec approval, before writing tests. Invoke with '/plan-tests path/to/spec.md' or 'plan tests', 'test planning', 'what tests do we need'."
contract:
  tags: [tdd, test-planning]
  state_source: spec
  inputs:
    params:
      - name: spec_path
        required: true
    gates:
      - field: "status"
        value: "Approved"
  outputs:
    mutates:
      - field: "Test Plan.status"
        sets_to: "Planned"
    side_effects: []
  next: [write-failing-test]
  human_gate: false
---

# Plan Tests

Creates a test plan and adds it to the spec document. This separates test planning (analytical) from test writing (implementation).

## Why This Skill Exists

Test planning and test writing are different cognitive tasks:
- **Planning** = "What scenarios need coverage?" (analytical)
- **Writing** = "How do I express this in code?" (implementation)

Separating them means:
- When tests miss edge cases → fix the planning
- When tests are flaky/poorly structured → fix the writing
- Each skill is simpler and more focused
- You can review the test plan before any code is written

## When to Use

- After a spec is approved
- Before `/write-failing-test`
- User says "plan tests", "what tests do we need", or "test planning"

## Prerequisites

1. Spec document exists and is approved
2. Path to spec provided as argument

## Instructions

### Step 1: Read and Parse the Spec

Read the spec document. Extract:

> See shared/spec-io.md for spec sections and how to extract Acceptance Criteria with Test Type.

**Gate check:** Verify `**Status:**` is `Approved`. If still `Draft`, stop: *"Spec hasn't been approved yet. Run `/spec-review` first."*

1. **Acceptance Criteria** - Each with its **Test Type** (Unit/Integration/E2E/Manual)
2. **Non-Goals** - What NOT to test
3. **Technical Notes** - Implementation hints that inform test structure

**Categorize criteria:**
- **Unit** → Automated (pure functions, business logic)
- **Integration** → Automated (database, API endpoints, service interaction)
- **E2E** → Automated (user flows, frontend behavior) - uses Playwright
- **Manual** → QA checklist only (email delivery, mobile apps, etc.)

> See `.claude/primitives/testing-conventions.md` for when to use each test type in this project.

### Step 2: Search for Existing Tests

**Before planning any new test files**, search for existing tests:

```bash
# Search for existing test files related to this feature
# Adapt patterns to the feature being planned
Glob: src/test/**/*feature-name*.test.ts
Glob: src/test/**/*related-module*.test.ts
Grep: "feature-name" in src/test/
```

Identify:
- Existing test files that cover related functionality
- Test patterns and conventions used in the project
- Shared setup code (beforeAll, fixtures) that can be reused

### Step 3: Group Criteria by Test Location

**Testing Philosophy:**
1. **Expand before create** - Add to existing test files when possible
2. **Test behaviors, not criteria** - Multiple criteria often share one test
3. **Module boundaries** - Tests belong where the code lives

**Create a grouping table:**

| Test File | Criteria | Rationale |
|-----------|----------|-----------|
| `existing-file.test.ts` (expand) | #1, #3, #5 | Same module, similar setup |
| `new-feature.test.ts` (create) | #2, #4 | New module, needs new file |
| (Manual - QA checklist) | #6 | Cannot automate |

### Step 4: Map Criteria to Tests

For each test file, plan the specific tests.

> See `shared/test-planning.md` for test granularity framework and decision flowchart.

**Quick reference:**
- **Combine into one test:** Same function call + different assertions, happy path flows
- **Split into separate tests:** Different inputs, different code paths, independent behaviors

For each planned test:
- Test description (`it('should...')`)
- Which criteria it covers
- Expected failure message (what will fail before implementation)

**For E2E tests:** See `shared/e2e-patterns.md` for E2E-specific planning guidance.

### Step 5: Add Test Plan to Spec

**Add a new section to the spec file** (before Technical Notes):

```markdown
## Test Plan

**Status:** Planned
**Total:** X criteria → Y automated tests + Z manual checks

### Automated Tests

**Expand:** `src/test/edge-functions/send-email.test.ts` (Integration)
| Test | Criteria | Expected Failure |
|------|----------|------------------|
| `it('accepts valid replyTo email')` | #1, #3 | "replyTo not implemented" |
| `it('stores replyTo in email queue')` | #4 | "column replyTo does not exist" |

**Create:** `src/test/edge-functions/send-email-validation.test.ts` (Unit)
| Test | Criteria | Expected Failure |
|------|----------|------------------|
| `it('rejects invalid replyTo format')` | #2 | "validateEmail is not a function" |

**Create:** `test/e2e/reply-to-email.e2e.py` (E2E)
| Test | Criteria | Expected Failure |
|------|----------|------------------|
| `test_user_can_reply_via_modal()` | #5 | "reply button not found" |

### Manual Checks (QA Checklist)
- #6: "Email reply goes to correct address in Outlook"
- #7: "Reply-to visible in Gmail mobile app"
```

> See shared/spec-io.md for the Test Plan section structure and status field format.

### Step 6: Update Spec Status

Change the Test Plan status line:
- From: `**Status:** Planned`
- Keep as Planned (write-failing-test will update to "Tests Written")

### Step 7: Present Summary and Hand Off

```
## Test Plan Complete

**Spec:** Documents/specs/42-feature-spec.md
**Criteria:** 7 total (5 automated, 2 manual)
**Test files:** 2 (1 expand, 1 create)

Test plan has been added to the spec. Review it, then run:
`/write-failing-test Documents/specs/42-feature-spec.md`
```

**THIS SKILL NOW ENDS.** User reviews the plan, then invokes `/write-failing-test`.

---

## What This Skill Does NOT Do

- ❌ Write actual test code (use `/write-failing-test`)
- ❌ Run tests
- ❌ Write implementation code
- ❌ Modify any files other than the spec

---

## Quality Checks

Before finalizing the plan, verify:

- [ ] Every Unit/Integration/E2E criterion has a planned test
- [ ] No test file is created when an existing file could be expanded
- [ ] Related criteria are grouped into single tests where appropriate (see `shared/test-planning.md`)
- [ ] E2E tests planned for user-facing behavior (see `shared/e2e-patterns.md`)
- [ ] Manual criteria are listed for QA, not planned as automated tests
- [ ] Expected failures are specific (not just "test will fail")

---

## Handoff

This skill hands off to:
- **`/write-failing-test`** - Writes the tests according to the plan
