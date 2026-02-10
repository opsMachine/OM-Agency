---
name: diagnose
description: "Bug investigation sub-agent. Receives triage context from the workflow manager, investigates codebase for root cause, and generates a draft bug spec. Dispatched by the manager after triage — do not invoke directly."
allowed-tools: Read, Grep, Glob, Bash, WebFetch, gh
contract:
  tags: [bug, diagnosis, investigation]
  state_source: github_issue
  inputs:
    params:
      - name: issue_number
        required: false
      - name: actual_behavior
        required: true
      - name: expected_behavior
        required: true
      - name: reproduction_steps
        required: false
      - name: started_when
        required: false
      - name: environment
        required: false
    gates: []
  outputs:
    mutates:
      - field: "status"
        sets_to: "Approved"
    side_effects: ["Creates bug spec in Documents/specs/"]
  next: [plan-tests, implement-direct]
  human_gate: false
---

## Purpose

Autonomous bug investigation. Receives triage context from the workflow manager (who already gathered details from the human and read the GitHub issue), investigates the codebase, identifies root cause, and generates a draft bug spec.

**You are a sub-agent.** Do NOT ask the user questions. All context is in your prompt.

## When This Runs

The workflow manager dispatches you after completing bug triage:
1. Manager reads the GitHub issue (if tracked)
2. Manager asks the human for context (actual/expected/repro/when/environment)
3. Manager dispatches you with all context pre-filled

## Step 1: Read Context

Read the triage context from your prompt. You should have:
- Issue number (or "untracked")
- Actual behavior
- Expected behavior
- Reproduction steps (may be "unknown")
- When it started (may be "unknown")
- Environment details (may be "unknown")

If the issue is tracked, read the full issue for additional context:

```bash
gh issue view <number> --json title,body,comments,labels
```

## Step 2: Investigate Root Cause

Search the codebase:
- Find the code path involved
- Check recent changes: `git log -p --since="2 weeks ago" -- <file>`
- Look for related issues or TODOs

Identify:
- **Where:** Which file(s) and function(s)
- **Why:** What's causing the incorrect behavior
- **When:** Under what conditions does it fail

## Step 3: Quick Security Check

- Could this bug be exploited? (auth bypass, data leak, injection)
- Does the fix touch sensitive areas? (auth, payments, PII)

If security-relevant, flag for extra review in your findings.

## Step 4: Generate Bug Spec

Create a spec file so downstream skills have a contract to work from.

**File path:** `Documents/specs/{issue-number}-{slug}-spec.md`
- If no issue number: `Documents/specs/bug-{slug}-spec.md`
- Slug from the bug title, e.g. `42-email-missing-replyto-spec.md`

**Use this template — fill from your investigation:**

```markdown
# Bug: {title}

**Issue:** #{number}
**Status:** Approved
**Created:** {YYYY-MM-DD}

## Problem Statement

**Actual:** {what's happening}
**Expected:** {what should happen}
**Root cause:** {where and why, from Step 2}

## Acceptance Criteria

Write criteria specific enough that an implementer can assess ✅/⚠️/❌ against each one.
Avoid vague phrasing — say exactly what should happen.

| # | Criterion | Test Type |
|---|-----------|-----------|
| 1 | {specific: e.g. "Clicking Save with empty name shows 'Name required' error"} | Unit \| Integration |
| 2 | {specific: e.g. "Email sends successfully when replyTo matches an auth.users record"} | Unit \| Integration |
| 3 | {regression: e.g. "Existing quotes still load correctly after migration"} | Unit \| Integration \| Manual |

## Non-Goals

- Not refactoring {related area} beyond the fix
- {other explicit exclusions}

## Security Considerations

- **Impact:** {from Step 3 — "none" is fine if not security-relevant}

## Technical Notes

**Files involved:** {from Step 2}
- `{file}` — {what's wrong and what needs to change}

**Reproduction:** {steps to trigger the bug}
```

**Key differences from feature specs:**
- Status is `Approved` immediately (diagnosis IS the review)
- Problem Statement has Actual/Expected/Root Cause (not "who benefits")
- No interview needed — diagnosis already gathered the information
- Lighter template — skip Assumptions & Constraints unless relevant

## Step 5: Return Findings

Report back to the manager with:

1. **Root cause summary** — what's broken and why (2-3 sentences)
2. **Files involved** — which files need changes
3. **Spec path** — where the bug spec was written
4. **Security flag** — yes/no, with details if yes
5. **Satisfaction assessment** — for each acceptance criterion you wrote:
   - ✅ Confident this criterion correctly captures the bug
   - ⚠️ Criterion written but unsure if it covers the full scope
   - ❌ Could not determine criterion (explain why)

> **End-of-skill check:** See `shared/primitive-updates.md`. Signals: gotchas discovered, non-obvious system behavior, domain terms encountered.

## Best Practices

1. **Reproduce first** — Don't guess; confirm you can trace the bug in code
2. **Be specific** — Exact file, line, and conditions
3. **Check recent changes** — Many bugs are regressions
4. **Don't fix yet** — Diagnosis only; fixes go through the implementation path
5. **Write assessable criteria** — Each criterion should be objectively verifiable
6. **Flag unknowns** — If you couldn't determine something, say so in your report
