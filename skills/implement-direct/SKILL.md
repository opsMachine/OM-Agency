---
name: implement-direct
description: "Implement a feature directly from spec without TDD. Use when tests aren't worth the overhead. Invoke with '/implement-direct path/to/spec.md' or 'just implement', 'implement directly', 'skip tests'."
contract:
  tags: [implementation, direct]
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
      - field: "status"
        sets_to: "Implemented"
    side_effects: []
  next: [qa-handoff]
  human_gate: true
---

# Implement Direct

Implements a feature from an approved spec using judgment, without writing tests first. You verify the result manually.

## Why This Skill Exists

TDD is valuable for complex logic but overkill for:
- UI/layout changes
- Simple CRUD operations
- Features you'll verify visually
- Rapid iteration where specs evolve

This skill implements with intelligence, not blind compliance.

## When to Use

| Use `/implement-direct` | Use TDD instead |
|------------------------|-----------------|
| UI components/styling | Complex business logic |
| Simple CRUD | Security-sensitive code |
| Features you'll test manually | Math/algorithms |
| Rapid prototyping | Code that's hard to verify visually |

## Prerequisites

1. Spec document exists and is approved
2. Path to spec provided as argument

## Instructions

### Step 1: Read and Understand the Spec

Read the spec document. Extract:
- **Problem Statement** - What problem are we solving?
- **Acceptance Criteria** - What does "done" look like?
- **Non-Goals** - What are we NOT doing?
- **Security Considerations** - What security patterns apply?
- **Technical Notes** - Implementation hints

> See shared/spec-io.md for spec sections and structure.
> See shared/security-lens.md for implementation-time security patterns.

**Think about intent, not just words.** The spec is a guide, not a legal contract.

### Step 2: Identify Existing Patterns

Before writing code, explore the codebase:
- How are similar features implemented?
- What patterns does this project use?
- What components/utilities already exist?

Match existing conventions. Don't invent new patterns.

### Step 3: Plan the Implementation

Create a brief mental model:
- What files need to change?
- What's the logical order of changes?
- Are there any ambiguities in the spec?

**If something seems wrong or unclear, ASK.** Don't blindly implement something that doesn't make sense.

### Step 4: Implement with Judgment

Work through each acceptance criterion. As you implement:

**DO:**
- Think about what the user actually needs
- Use appropriate HTML elements (textarea vs input, etc.)
- Follow existing code patterns
- Make reasonable inferences when spec is ambiguous

**DON'T:**
- Implement something that seems wrong just because the spec says it
- Add features not in the spec
- Over-engineer or add unnecessary abstraction
- Skip error handling

**Flag concerns as you go:**
```
⚠️ The spec says "text field" but this looks like it needs a textarea
   for multi-line input. Proceeding with textarea. Let me know if wrong.
```

### Step 5: Verify It Works

**Before marking work complete, follow the testing requirements from `shared/testing-standards.md`.**

After implementation:

**1. Run Automated Tests**
- Execute test suite: `npm test` (or project-specific command)
- Verify all existing tests still pass (no regressions)
- Quick fixes require full testing too — no shortcuts

**2. Manual Verification**
- **Happy path:** Primary user flow works as specified
- **Error cases:** Invalid input handled, error messages display properly
- **Edge cases:** Test falsification scenarios from spec (if present)
- **UI verification:** No console errors, correct rendering, data persists

**3. Document Testing**
Record what you tested and results:
```
### Verification
- Tested: form submission happy path (✅ works)
- Tested: invalid email handling (✅ error displays)
- Tested: edge case from spec (empty description) (✅ handled)
- Could not verify: rate limiting (no test infrastructure)
```

Report what you verified vs. what you couldn't. Don't claim full verification if you only checked that it compiles.

**Don't claim it's done if it doesn't build or if tests fail.**

### Step 6: Satisfaction Assessment

Before claiming done, re-read each acceptance criterion from the spec.
For each, assess honestly:
- ✅ **Satisfied** — implemented and verified
- ⚠️ **Unsure** — implemented but couldn't fully verify (explain why)
- ❌ **Not satisfied** — not implemented or known gap
- 🔒 **Security** — one line summarizing security posture (see `shared/security-lens.md` Review-Time section)

Include this assessment in your completion report. The manager uses it
to decide whether to present Gate B or ask you to fix gaps first.

### Step 7: Summarize Locally

```
## Implementation Complete

**Spec:** Documents/specs/42-feature-spec.md
**Files changed:** 3

### Changes
- `src/components/FeedbackForm.tsx` - Added textarea for description
- `src/api/feedback.ts` - New endpoint for submission
- `supabase/migrations/xxx_feedback.sql` - New table

### Satisfaction Assessment
- ✅ Form accepts multi-line feedback
- ✅ Submission persists to database
- ⚠️ 500 char limit — implemented, but spec didn't specify a limit (inferred from codebase)
- 🔒 Security: RLS enabled on feedback table, input sanitized at edge function

### Verification
- Verified: form submission persists correctly (tested locally)
- Could not verify: rate limiting (no test infrastructure)

### Decisions Made
- Used textarea instead of input for description (multi-line content)
- Added 500 char limit based on similar forms in codebase
```

Update the spec's `**Status:**` from `Approved` to `Implemented`.

> See shared/spec-io.md for how to update the status field.

> **End-of-skill check:** See `shared/primitive-updates.md`. Signals: new/changed packages, new scripts, new directories in src/.

### Step 8: Prepare QA Handoff

Create clear testing instructions for QA using the template from `shared/testing-standards.md`:

- Staging environment link and credentials
- Step-by-step happy path test instructions
- Edge cases to verify (from falsification analysis if present)
- Expected behavior vs what should NOT happen
- Known limitations

Include this in your completion report so the manager can pass it to qa-handoff.

### Step 9: Hand Off

```
Implementation complete.

Ready for manager review.
```

---

## Red Flags to Raise

Stop and ask if you encounter:

- **Contradictory requirements** - Spec says X but also implies Y
- **Missing information** - Can't implement without knowing Z
- **Seems wrong** - "This will create a bad UX because..."
- **Scope creep** - Implementing this properly requires touching A, B, C not mentioned in spec

Don't silently make bad decisions. Surface them.

---

## What This Skill Does NOT Do

- ❌ Write tests (that's your choice to add later)
- ❌ Blindly follow spec when it seems wrong
- ❌ Add features beyond the spec
- ❌ Skip the human review step
- ❌ Post to GitHub (manager handles this after review)

---

## Handoff

This skill hands off to:
- **You** - Manual verification of the implementation
- **`/qa-handoff`** - When ready for QA testing
