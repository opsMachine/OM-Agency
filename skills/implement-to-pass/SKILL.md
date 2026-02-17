---
name: implement-to-pass
description: "Implement minimum code to pass a failing test. Use after /write-failing-test confirms red phase. Invoke with '/implement-to-pass' or 'green phase', 'make test pass', 'implement the test'."
contract:
  tags: [tdd, implementation, green-phase]
  state_source: spec
  inputs:
    params: []
    gates:
      - field: "Test Plan.status"
        value: "Tests Written"
  outputs:
    mutates:
      - field: "Test Plan.status"
        sets_to: "Passing"
    side_effects: []
  next: [qa-handoff]
  human_gate: true
---

# Implement to Pass (Green Phase)

Implements the MINIMUM code needed to make ALL failing tests pass. Works autonomously through each failing test. Only pauses when stuck.

## Why This Skill Exists

TDD's green phase is about writing just enough code to pass the test—no more. This skill focuses solely on that goal, preventing scope creep and over-engineering.

## When to Use

- After `/write-failing-test` has confirmed all tests fail correctly
- When you have red tests waiting for implementation

## Prerequisites

1. Failing tests exist (from `/write-failing-test`)
2. All tests fail for the right reason (features don't exist)

## Instructions

### Step 1: Identify All Failing Tests

**Gate check:** Find the active spec in `Documents/specs/` and verify Test Plan `**Status:**` is `Tests Written`. If not, stop: *"Tests haven't been written yet. Run `/write-failing-test` first."*

Run the full test suite. List all failing tests from the spec.

If no failing tests exist:
"No failing tests found. Run `/write-failing-test` first."

### Step 2: Loop Through All Failing Tests

For EACH failing test, perform steps 3-6. Work autonomously—do not wait for user input between tests.

### Step 3: Understand What's Needed

Read the test. Identify:
- What function/component/endpoint is being tested
- What behavior is expected
- What the minimum implementation looks like
- Test type (Unit/Integration/E2E)
- Security context from the spec's Security Considerations section

> See `.claude/primitives/testing-conventions.md` for project-specific implementation patterns.
> See `shared/security-lens.md` for implementation-time security patterns.

### Step 4: Write Minimum Code

Implement ONLY what's needed to pass the test:
- No extra features
- No premature optimization
- No "while I'm here" additions
- No code that isn't tested

**For E2E test failures:**
- Implement the frontend behavior (UI, interactions, routing)
- Update components, pages, or client-side logic
- See `shared/e2e-patterns.md` if you need to understand what the E2E test is verifying

### Step 5: Run the Test

Run the test(s) and verify the targeted test now passes.

### Step 6: Confirm Pass and Continue

If test passes: Mark complete, move to next failing test.

If test still fails (after 3 attempts): Pause and report:
```
STUCK on test: "{test name}"
Attempts: 3
Error: [what's failing]
Need: [what you need to proceed]
```

If other tests broke (regression): Fix before continuing.

### Step 7: Refactor (After All Pass)

Once all tests pass:
1. Look for obvious cleanup opportunities
2. Refactor while keeping tests green
3. Re-run full suite after refactoring

### Step 8: Beyond Tests — Manual Verification

**Even though all tests pass, follow the testing requirements from `shared/testing-standards.md`.**

Tests can be narrower than criteria — a passing suite doesn't guarantee full satisfaction.

**Manual Verification Required:**
- **Happy path:** Run through primary user flow in the actual app
- **Error cases:** Verify error messages display correctly (not just that exceptions are thrown)
- **Edge cases:** Test falsification scenarios from spec (if present)
- **UI verification:** No console errors, correct rendering, data persists after refresh

**Document what you tested:**
```
### Beyond Tests Verification
- Manually tested: quote creation happy path (✅ works)
- Manually tested: invalid email handling (✅ UI shows error correctly)
- Could not verify: production email delivery (requires live environment)
```

### Step 9: Satisfaction Assessment

Re-read each acceptance criterion from the spec. For each, assess honestly:
- ✅ **Satisfied** — implemented and verified (test covers this + manually verified)
- ⚠️ **Unsure** — implemented but tests don't fully cover this criterion (explain why)
- ❌ **Not satisfied** — not implemented or known gap
- 🔒 **Security** — one line summarizing security posture (see `shared/security-lens.md` Review-Time section)

Include this assessment in your completion report. The manager uses it
to decide whether to present Gate B or ask you to fix gaps first.

### Step 10: Prepare QA Handoff

Create clear testing instructions for QA using the template from `shared/testing-standards.md`:

- Staging environment link and credentials
- Step-by-step happy path test instructions
- Edge cases to verify (from falsification analysis if present)
- Expected behavior vs what should NOT happen
- Known limitations

Include this in your completion report so the manager can pass it to qa-handoff.

### Step 11: Complete and Hand Off

After ALL tests pass:

```
## Green Phase Complete

All {n} tests now passing:

1. ✅ "{test 1}" - implemented: [brief description]
2. ✅ "{test 2}" - implemented: [brief description]
...

Full test suite: ✅ {x} passed, 0 failed

Ready for manager review.
```

> **End-of-skill check:** See `shared/primitive-updates.md`. Signals: new/changed packages, new scripts, new directories in src/.

**THIS SKILL NOW ENDS.**

---

## Output Format (Final Summary)

```
## Green Phase Complete

**Spec:** Documents/specs/reply-to-email-spec.md
**Tests passed:** 13/13

### Implementation Summary

1. ✅ "send-email requires replyTo parameter"
   - Added: validation check in send-email/index.ts

2. ✅ "send-email validates replyTo against auth.users"
   - Added: validateReplyTo() helper function

... [all tests listed]

### Files Modified
- supabase/functions/send-email/index.ts
- supabase/migrations/20260127_office_emails.sql
- src/features/quotes/utils/quoteActions.ts

### Satisfaction Assessment
- ✅ Email sends with replyTo parameter
- ✅ replyTo validated against auth.users
- ⚠️ Error message wording — test verifies error thrown, but exact copy may differ from spec
- 🔒 Security: JWT verified in edge function, replyTo validated against whitelist table with RLS

### Verification
- Verified: edge function returns 400 for invalid replyTo (tested via test suite)
- Could not verify: email header delivery (requires external mail service)

### Full Test Suite
✅ 470 passed, 0 failed

Ready for manager review.
```

---

## Database Changes

If implementation requires database changes:

**CRITICAL: Local development only. Never apply migrations to remote.**

1. **Create migration file:**
   ```bash
   supabase migration new descriptive_name
   ```

2. **Write SQL** in `supabase/migrations/[timestamp]_name.sql`

3. **Apply to local database** (use ONE of these):
   ```bash
   supabase db reset          # Resets local DB, applies all migrations (safest)
   supabase migration up      # Applies pending migrations to local
   ```

**NEVER run these commands:**
- ❌ `supabase db push` - Can push to remote if linked
- ❌ `supabase db push --db-url <remote>` - Explicitly targets remote
- ❌ `supabase link` then `supabase db push` - Pushes to linked project
- ❌ Direct SQL on remote databases

**Remote deployments happen via:**
- GitHub Actions CI/CD pipeline
- Explicit deployment scripts with human approval
- Never during local development

**Verify you're working locally:**
```bash
supabase status
# DB URL should show: postgresql://postgres:postgres@127.0.0.1:54322/postgres
```

---

## What NOT to Do

- ❌ Add features not required by tests
- ❌ Stop after one test (complete ALL failing tests)
- ❌ Wait for user input between tests
- ❌ Leave other tests broken (fix regressions)
- ❌ Push database migrations to remote
- ❌ Optimize before all tests pass

---

## When to Pause

Only pause and ask user for help when:
- Stuck on same error 3+ times for one test
- Implementation requires changes to Non-Goals
- Blocking issue (missing dependency, unclear requirement)
- Security concern with proposed approach

Do NOT pause for:
- Normal implementation work
- Moving to next test
- Minor refactoring decisions

---

## Scope Enforcement

Throughout implementation, actively check:

| Situation | Action |
|-----------|--------|
| Required by the test | Implement it |
| Listed in Non-Goals | Do not implement |
| Nice to have but not tested | Ask user first |
| "While I'm here..." | Stop. Focus on the test. |

---

## Security Check (Before Completing)

Quick verification:
- [ ] No hardcoded secrets
- [ ] User input validated
- [ ] Auth/authz checks in place (if applicable)
- [ ] RLS policies added (if new tables)

---

## Handoff

This skill hands off to:
- **`/qa-handoff`** - Posts testing checklist to GitHub issue
