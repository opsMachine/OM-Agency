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

## Falsification

> What could go wrong? What assumptions might be wrong? What edge cases could break this?
> This section helps the implementer and verifier know where to look for problems.

- {scenario that could invalidate the happy path}
- {edge case worth testing}
- {assumption that might not hold}

## Assumptions & Constraints

- {dependencies, technical constraints, assumptions}

## Implementation Brief

> Context for one-shot implementation. The implementer reads this to understand WHERE and HOW to build.

- **Files likely affected:** {list files/modules that will need changes}
- **Patterns to follow:** {existing patterns in the codebase to match}
- **Test infrastructure:** {test setup needed — existing test utils, fixtures, mocking patterns}

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

## Implementation Brief

- **Files involved:** {files that need changes, with what's wrong in each}
- **Reproduction:** {steps to trigger the bug}
```

**Key differences from feature specs:**
- Title prefixed with `Bug:`
- Status starts at `Approved` (diagnosis IS the review)
- Problem Statement uses Actual/Expected/Root Cause format
- Skips Assumptions & Constraints and Open Questions

Downstream skills (`implement`, `verify`) consume bug specs identically to feature specs — same header format, same Acceptance Criteria table, same status field.

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
| Falsification | Edge cases, assumptions, failure scenarios | `interview` |
| Assumptions & Constraints | Dependencies, technical constraints | `interview` |
| Implementation Brief | Files, patterns, test infra for one-shot execution | `interview` |
| Technical Notes | Implementation hints | `interview` |
| Open Questions Resolved | Decisions made during interview | `interview` |

---

## Header Format

The top of the spec file looks like:

```markdown
# {Feature Title}

**Issue:** #{number}
**Status:** {Draft | Approved | Implemented}
**Created:** {date}
```

### Reading status
Find the line starting with `**Status:**`. The value after the colon is the current status.

### Updating status
Replace the value on that line:
- `**Status:** Draft` → `**Status:** Approved` (human approves at Gate A)
- `**Status:** Approved` → `**Status:** Implemented` (`implement` sets this on completion)

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

### How skills use criteria
- `implement` reads the Test Type column to decide which criteria get automated tests (Unit/Integration) and which become manual checks
- `verify` reads criteria to independently validate that each one is satisfied in the implementation
- `qa-handoff` extracts Manual criteria for the QA checklist

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

## Implementation Brief Section

```markdown
## Implementation Brief

- **Files likely affected:** {list files/modules that will need changes}
- **Patterns to follow:** {existing patterns in the codebase to match}
- **Test infrastructure:** {test setup needed — existing test utils, fixtures, mocking patterns}
```

This section is filled by `interview` after exploring the codebase. It gives the `implement` skill enough context to one-shot the feature without re-exploring from scratch. The more specific this section is, the better the implementation.

---

## Common Operations

### "What's the spec status?"
Read the `**Status:**` line in the header. Values: `Draft`, `Approved`, `Implemented`.

### "What criteria are automated vs manual?"
Read the Acceptance Criteria table. Filter by Test Type column.

### "What files will this change?"
Read the Implementation Brief section. The "Files likely affected" line lists the expected scope.
