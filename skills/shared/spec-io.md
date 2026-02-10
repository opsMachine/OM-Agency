# Spec I/O — Shared Reference

How to read and write spec files. Every skill that touches a spec references this file for structure, field locations, and update patterns.

---

## Location

Specs live at: `Documents/specs/{issue-number}-{slug}-spec.md`

Example: `Documents/specs/42-dark-mode-spec.md`

If no issue number, use a descriptive slug only.

---

## Creating a Spec

New specs are created by `/interview`. Use this template:

```markdown
# {Feature Title}

**Issue:** #{number}
**Status:** Draft
**Created:** {YYYY-MM-DD}

## Problem Statement

{Why this matters and who benefits}

## Acceptance Criteria

| # | Criterion | Test Type |
|---|-----------|-----------|
| 1 | {testable criterion} | Unit \| Integration \| Manual |

## Non-Goals

- {what this feature explicitly does NOT do}

## Security Considerations

> Fill each prompt. Write "N/A — {reason}" if genuinely not applicable. See `shared/security-lens.md` for guidance.

- **Data flow:** {what data enters, moves through, and leaves this feature}
- **Trust boundaries:** {where user input crosses into trusted operations}
- **Auth model:** {who can do what, and how that's enforced}
- **Failure modes:** {what happens if auth fails, input is malicious, or a service is down}
- **RLS:** {new tables or policy changes needed — reference supabase-security if yes}

## Assumptions & Constraints

- {dependencies, technical constraints, assumptions}

## Technical Notes

{implementation hints, existing patterns to follow}

## Open Questions Resolved

{decisions made during interview with reasoning}
```

---

## Creating a Bug Spec

Bug specs are created by `/diagnose` after root cause is identified. Lighter than feature specs — no interview needed.

```markdown
# Bug: {title}

**Issue:** #{number}
**Status:** Approved
**Created:** {YYYY-MM-DD}

## Problem Statement

**Actual:** {what's happening}
**Expected:** {what should happen}
**Root cause:** {where and why}

## Acceptance Criteria

Each criterion must be specific enough for an implementer to assess ✅ satisfied / ⚠️ unsure / ❌ not satisfied.

| # | Criterion | Test Type |
|---|-----------|-----------|
| 1 | {specific: e.g. "Clicking Save with empty name shows 'Name required' error"} | Unit \| Integration |

## Non-Goals

- {explicit exclusions}

## Security Considerations

- **Impact:** {from diagnosis — "none" if not security-relevant}

## Technical Notes

**Files involved:**
- `{file}` — {what's wrong and what needs to change}

**Reproduction:** {steps to trigger the bug}
```

**Key differences from feature specs:**
- Title prefixed with `Bug:`
- Status starts at `Approved` (diagnosis IS the review)
- Problem Statement uses Actual/Expected/Root Cause format
- Skips Assumptions & Constraints and Open Questions

Downstream skills (`plan-tests`, `write-failing-test`, `implement-direct`) consume bug specs identically to feature specs — same header format, same Acceptance Criteria table, same status field.

---

## Sections Map

A complete spec has these sections, in order:

| Section | Purpose | Who writes it |
|---------|---------|---------------|
| Header | Issue link, status line | `interview` |
| Problem Statement | Why this matters, who benefits | `interview` |
| Acceptance Criteria | Testable criteria with Test Type column | `interview` |
| Non-Goals | Explicit exclusions | `interview` |
| Security Considerations | Data sensitivity, auth, RLS | `interview` |
| Assumptions & Constraints | Dependencies, technical constraints | `interview` |
| Test Plan | Planned tests mapped to criteria | `plan-tests` |
| Technical Notes | Implementation hints | `interview` |
| Open Questions Resolved | Decisions made during interview | `interview` |

---

## Header Format

The top of the spec file looks like:

```markdown
# {Feature Title}

**Issue:** #{number}
**Status:** {Draft | Approved}
**Created:** {date}
```

### Reading status
Find the line starting with `**Status:**`. The value after the colon is the current status.

### Updating status
Replace the value on that line:
- `**Status:** Draft` → `**Status:** Approved` (human does this after spec-review)
- `**Status:** Approved` → `**Status:** Implemented` (`implement-direct` sets this on completion)

---

## Acceptance Criteria

Format: a table with columns `#`, `Criterion`, `Test Type`.

```markdown
## Acceptance Criteria

| # | Criterion | Test Type |
|---|-----------|-----------|
| 1 | API returns 400 if email missing | Unit |
| 2 | Email sends via Graph API | Manual |
| 3 | Preference persists across sessions | Integration |
```

**Test Type values:**
- `Unit` — isolated code test, mocks OK
- `Integration` — requires real DB/services
- `Manual` — cannot automate, goes to QA checklist

### Extracting criteria for QA
Pull all rows. Manual criteria become the QA checklist in `/qa-handoff`. Unit and Integration criteria become automated tests in `/plan-tests`.

---

## Test Plan Section

Added by `/plan-tests` after spec approval. Structure:

```markdown
## Test Plan

**Status:** {Planned | Tests Written | Passing}

**Total:** X criteria → Y automated tests + Z manual checks

### Automated Tests

**Expand:** `src/test/path/existing-file.test.ts`
| Test | Criteria | Expected Failure |
|------|----------|------------------|
| `it('does X')` | #1, #3 | "X not implemented" |

**Create:** `src/test/path/new-file.test.ts`
| Test | Criteria | Expected Failure |
|------|----------|------------------|
| `it('does Y')` | #2 | "Y is not a function" |

### Manual Checks (QA Checklist)
- #4: "Verify Z in browser"
```

### Reading Test Plan status
Find `**Status:**` inside the `## Test Plan` section (not the header status — that's the spec status). Same pattern: value after the colon.

### Updating Test Plan status
- `plan-tests` sets: `**Status:** Planned`
- `write-failing-test` sets: `**Status:** Tests Written`
- `implement-to-pass` sets: `**Status:** Passing`

Replace the value on the status line within the Test Plan section.

---

## Security Considerations Section

```markdown
## Security Considerations

> Fill each prompt. Write "N/A — {reason}" if genuinely not applicable. See `shared/security-lens.md` for guidance.

- **Data flow:** {what data enters, moves through, and leaves this feature}
- **Trust boundaries:** {where user input crosses into trusted operations}
- **Auth model:** {who can do what, and how that's enforced}
- **Failure modes:** {what happens if auth fails, input is malicious, or a service is down}
- **RLS:** {new tables or policy changes needed — reference supabase-security if yes}
```

Read this when implementing to know what security checks apply. Reference `shared/security-lens.md` for the design-time questions and `supabase-security/SKILL.md` for Supabase-specific patterns.

---

## Common Operations

### "Does this spec have a test plan?"
Check if a `## Test Plan` section exists in the file.

### "What's the spec status?"
Read the `**Status:**` line in the header. Values: `Draft`, `Approved`, `Implemented`.

### "What criteria are automated vs manual?"
Read the Acceptance Criteria table. Filter by Test Type column.

### "What test files does the plan specify?"
Read the Test Plan section. Look for **Expand:** and **Create:** lines — those are the test file paths.
