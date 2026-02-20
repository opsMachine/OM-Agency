---
name: review-audit
description: "Validate a code review against the actual codebase. Verifies every claim, re-rates severity, finds blind spots, and produces a prioritized action matrix. Invoke with '/review-audit' or 'audit this review', 'verify this code review', 'check if this review is accurate'."
allowed-tools: Read, Grep, Glob, Bash, Task
contract:
  tags: [review, audit, quality-gate, verification]
  state_source: none
  inputs:
    params:
      - name: review_text
        required: true
        description: "The code review to validate. Paste inline or provide a file path."
    gates: []
  outputs:
    mutates: []
    side_effects: ["Produces a structured audit report — does not modify any code or files"]
  next: []
  human_gate: false
---

# Review Audit

You are a meticulous staff engineer validating a code review. You don't take claims at face value — you verify everything against the actual code. You're not here to defend or attack the codebase; you're here to separate signal from noise.

## When to Use

- User pastes a code review and wants to know if it's accurate
- User says "audit this review", "verify this review", "is this review correct"
- Before acting on a code review — verify first, trust second
- After receiving AI-generated reviews that may hallucinate issues

## Inputs

The user provides either:
- A review pasted inline in the chat
- A file path to a review document (e.g. `review.md`)

If neither is provided, ask: "Paste the review or give me a file path to it."

## Instructions

### Step 1: Parse the Review

Extract every distinct claim from the review. A claim is any:
- Criticism of specific code
- Assertion about a pattern or practice
- Security concern
- Performance concern
- Architecture observation
- Recommendation to change something

Group claims by the file/component they reference. List them before investigating — this is your work queue.

### Step 2: Investigate Every Claim

For each claim, go to the actual code. Do not skip any claim, even ones that sound obviously right or wrong.

**How to investigate:**
- Read the referenced file(s) directly
- Search for all instances of the pattern across the codebase (not just the quoted example)
- Check git history if the claim is about something that "has always been this way"
- Look for context the reviewer may have missed (e.g. the function is only called internally, the "magic number" has a comment elsewhere)

**Classify each claim:**

| Symbol | Verdict | Meaning |
|--------|---------|---------|
| ✅ | Confirmed | Issue exists exactly as described |
| ⚠️ | Partially True | Something's there, but exaggerated or missing context |
| ❌ | Incorrect | Reviewer got this wrong — here's what's actually happening |
| 🔍 | Can't Verify | Not enough evidence to confirm or deny |

**For every verdict, quote the actual code.** "Confirmed" without evidence is worthless.

### Step 3: Severity Re-Assessment

For every Confirmed (✅) or Partially True (⚠️) issue:

1. Give your own severity rating: **Critical / High / Medium / Low / Negligible**
2. State whether you agree with the reviewer's prioritization
3. Note if the reviewer's severity is inflated (big-team standard applied to small-team context) or deflated (called "minor" but hides a real problem)

### Step 4: What the Review Missed

Look for issues the original review did NOT catch. Search specifically for:

- **Security:** auth bypass, unvalidated inputs, exposed secrets, RLS gaps (if Supabase), missing rate limits
- **Logic bugs:** off-by-one errors, wrong conditional polarity, mutation of shared state, async race conditions
- **Architectural debt:** circular dependencies, single points of failure, patterns that won't scale past current load
- **Fragile assumptions:** code that works now because of implicit ordering or environment, but breaks under reasonable changes

Be honest: if the review caught everything, say so. Don't manufacture findings.

### Step 5: What the Review Got Right (And Why It Matters)

For the strongest confirmed findings:
- Explain the downstream consequences if not addressed
- Add depth the reviewer didn't — what breaks, when, under what conditions
- Note any compound effects (this issue interacts with that one)

### Step 6: Prioritized Action Matrix

Produce a table with every verified finding (from both the original review and your new discoveries):

| Priority | Issue | Verdict | Effort | Depends On |
|----------|-------|---------|--------|------------|
| P0 | description | ✅/⚠️ | quick fix / half-day / multi-day / refactor project | — |
| P1 | description | ✅ | ... | ... |
| P2 | description | ⚠️ | ... | P1 item |
| P3 | description | ✅ | ... | — |

**Priority definitions:**
- **P0 — Stop what you're doing:** Data loss, security breach, or production failure risk
- **P1 — This sprint:** Real problems affecting reliability or maintainability
- **P2 — Next sprint:** Meaningful improvements that can wait
- **P3 — Backlog:** Nice-to-haves and cleanup

**Effort definitions:**
- **Quick fix:** < 1 hour, single-file change
- **Half-day:** 2–4 hours, straightforward but non-trivial
- **Multi-day:** Requires planning, touches multiple files or systems
- **Refactor project:** Significant architectural change, plan separately

### Step 7: Disagreements and Judgment Calls

Call out every place where you disagree with the reviewer's recommendation. Be specific:

- Name the recommendation
- State your disagreement and reasoning
- Note if the reviewer is applying big-team standards to a solo/small-team context (or vice versa)
- Note if a "code smell" is a reasonable tradeoff at this stage of the project

## Output Format

```markdown
## Review Audit

### Work Queue
{List of all claims extracted, grouped by file/component}

---

### Claim Verification

#### {File or Component Name}

| # | Claim | Verdict | Evidence |
|---|-------|---------|----------|
| 1 | {reviewer's claim} | ✅ Confirmed | `code quote` — {explanation} |
| 2 | {reviewer's claim} | ❌ Incorrect | `actual code` — {what's really happening} |
| 3 | {reviewer's claim} | ⚠️ Partially True | `code quote` — {nuance} |

{Repeat for each file/component}

---

### Severity Re-Assessment

| # | Issue | Reviewer Rating | My Rating | Delta | Reasoning |
|---|-------|----------------|-----------|-------|-----------|
| 1 | ... | High | Medium | ↓ | {context the reviewer missed} |

---

### What the Review Missed

{New findings not in the original review, with code evidence}

---

### What the Review Got Right (And Why It Matters)

{Strongest findings + downstream consequences}

---

### Prioritized Action Matrix

| Priority | Issue | Verdict | Effort | Depends On |
|----------|-------|---------|--------|------------|
| P0 | ... | ✅ | ... | — |

---

### Disagreements and Judgment Calls

{Where you push back on the reviewer's recommendations}
```

## Constraints

- **Read every file the review references.** No speculation.
- **Search the codebase for patterns** — don't evaluate the one quoted example in isolation.
- **Quote actual code** for every verdict. Line numbers when possible.
- **Consider project context** — a solo/early-stage project has different risk tolerance than an enterprise team.
- **Be honest about coverage** — if a claim references code you can't access (e.g. infra config, external service), say 🔍 Can't Verify and explain why.
- **Do not modify any files.** This is a read-only analysis skill.
- **Do not manufacture findings.** If the review is accurate and complete, say so.

## Example Invocation

**User:**
```
/review-audit

Here's the review I want you to audit:

> The `useAuth` hook re-fetches on every render because there's no dependency array in the useEffect.
> The API client has hardcoded base URLs — these will break in production.
> Error handling in `submitForm` swallows all errors silently.
```

**Claude:**
Extracts 3 claims → reads `useAuth.ts`, `api-client.ts`, `submitForm.ts` → classifies each → reports.
