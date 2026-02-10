---
name: write-failing-test
description: "Write failing tests for all planned acceptance criteria from the test plan. Use after /plan-tests, before implementation. Invoke with '/write-failing-test path/to/spec.md' or 'write failing test', 'red phase', 'start TDD'."
contract:
  tags: [tdd, testing, red-phase]
  state_source: spec
  inputs:
    params:
      - name: spec_path
        required: true
    gates:
      - field: "Test Plan.status"
        value: "Planned"
  outputs:
    mutates:
      - field: "Test Plan.status"
        sets_to: "Tests Written"
    side_effects: []
  next: [implement-to-pass]
  human_gate: false
---

# Write Failing Test (Red Phase)

Writes failing tests according to the test plan in the spec. Works autonomously through each planned test until all have properly failing tests.

## Why This Skill Exists

TDD requires seeing tests fail before implementing. This skill executes the test plan created by `/plan-tests`, writing all failing tests that define the feature scope.

## When to Use

- After `/plan-tests` has added a test plan to the spec
- Before any implementation begins

## Prerequisites

1. Spec document exists and is approved
2. **Test Plan section exists in the spec** (created by `/plan-tests`)
3. Path to spec provided as argument
4. **Test infrastructure is running** (see Step 0)

## Instructions

### Step 0: Pre-Flight Infrastructure Check

**Before writing any tests**, verify ALL infrastructure is ready.

> See `.claude/primitives/testing-conventions.md` for project-specific infrastructure requirements.

**Run these checks:**
```bash
# 1. Docker running
docker info

# 2. Supabase running
supabase status

# 3. Test command works
npm test  # Should run even if 0 tests
```

**Required state:**
- ✅ Docker info returns successfully (not "Cannot connect to Docker daemon")
- ✅ Supabase status shows all services running (DB URL: `127.0.0.1:54322`)
- ✅ npm test runs without errors (may show 0 tests, that's fine)

**If ANY check fails:**
1. Report the specific failure to user
2. Provide fix command (e.g., "Run `supabase start`")
3. STOP - do not proceed until user confirms fix

**Only proceed when ALL checks pass.**

**CRITICAL:** Skipped tests are NOT acceptable. If tests skip due to missing infrastructure, this is a BLOCKING failure. Never claim "Ready for implementation" with skipped tests.

### Step 1: Read the Spec and Test Plan

Read the spec document. Locate the **## Test Plan** section.

> See shared/spec-io.md for Test Plan section structure and how to read the status field.

**Gate check:** Verify Test Plan `**Status:**` is `Planned`. If already `Tests Written` or `Passing`, tests have already been written — stop.

**If no Test Plan section exists:**
```
This spec doesn't have a test plan yet. Run `/plan-tests path/to/spec.md` first.
```

Extract from the Test Plan:
- Which test files to expand vs create
- Each planned test with its criteria and expected failure
- Manual checks (skip these - they're for QA)

### Step 2: Loop Through All Test Files

For EACH **test file** in the plan, perform steps 3-5. Work autonomously — do not pause between files.

The manager will review all tests together when you report back.

### Step 3: Write the Tests

Write tests according to the plan. The plan tells you:
- File to create or expand
- Test descriptions (`it('should...')`)
- Which criteria each test covers
- Test type (Unit/Integration/E2E)

**When expanding existing tests:**
- Look for existing `describe` blocks that match
- Add new `it` blocks within existing structure
- Share setup code (beforeAll, test fixtures)

**Test Type-Specific Guidance:**

**For Unit/Integration tests (TypeScript/JavaScript):**
> See `.claude/primitives/testing-conventions.md` for project-specific patterns and examples.

**For E2E tests (Playwright/Python):**
> See `shared/e2e-patterns.md` for reconnaissance-then-action pattern and server management.

Use `skills/webapp-testing/scripts/with_server.py` for server lifecycle management.

**Meaningful Test Checklist (MUST pass all for EACH test):**

1. **Does the test CALL the code under test?**
   - ❌ Bad: Test only sets up data and asserts setup worked
   - ✅ Good: Test calls the function/endpoint/UI being tested

2. **Does the assertion verify the BEHAVIOR in the criterion?**
   - ❌ Bad: `expect(response.status).not.toBe(400)` (proves nothing)
   - ❌ Bad: `expect(data).toBeTruthy()` (just checks something exists)
   - ✅ Good: `expect(response.error).toMatch(/replyTo.*required/)` (verifies specific behavior)

3. **Will the test PASS when the feature is correctly implemented?**
   - If you can't answer "yes" clearly, the test doesn't test the criterion

4. **Is this test deferring to a non-existent test?**
   - ❌ Never write: "actual verification is in integration test"
   - If you can't test it here, flag it and ask

> See `.claude/primitives/testing-conventions.md` for good vs bad test examples specific to this project.

### Step 4: Run the Test

Run the test using the project's test command (usually `npm test`).

### Step 5: Verify Correct Failure

The test MUST fail for the RIGHT reason:

**Good failures (feature doesn't exist):**
- "Cannot find module '../components/MyComponent'"
- "Expected true but received undefined"
- "TypeError: myFunction is not a function"

**Bad failures (test infrastructure problems):**
- Syntax errors in the test file
- Missing test dependencies
- Configuration issues
- Typos in import paths
- **SKIPPED TESTS** (Supabase not running, Docker not running, etc.)

**Skipped tests are NOT acceptable.** A skipped test proves nothing. If tests skip:
1. Stop immediately
2. Fix the infrastructure (see Step 0)
3. Re-run tests
4. Only proceed when tests actually FAIL (not skip)

If "bad failure": fix and retry (up to 3 attempts per test).

### Step 6: Update Test Plan Status

After all tests are written, update the spec's Test Plan section:
- From: `**Status:** Planned`
- To: `**Status:** Tests Written`

> See shared/spec-io.md for how to update the Test Plan status field.

### Step 7: Complete and Hand Off

After ALL planned tests have failing tests:

```
## Red Phase Complete

**Spec:** Documents/specs/42-feature-spec.md
**Tests written:** X tests across Y files

### Summary

**Expanded:** src/test/edge-functions/send-email.test.ts
- ✅ `it('accepts valid replyTo email')` - fails: "replyTo not implemented"

**Created:** src/test/edge-functions/send-email-validation.test.ts
- ✅ `it('rejects invalid replyTo format')` - fails: "validateEmail is not a function"

Ready for implementation. Run `/implement-to-pass` to continue.
```

**THIS SKILL NOW ENDS.** Do not proceed to implementation.

---

## What NOT to Do

- ❌ Write implementation code
- ❌ Stop after one test (complete ALL tests in the plan)
- ❌ Wait for user input between tests
- ❌ Skip running tests
- ❌ Accept tests that pass (means nothing to implement)
- ❌ Accept tests that fail for wrong reasons
- ❌ Write placeholder tests that don't call the code under test
- ❌ Write tests that "defer to integration tests"
- ❌ Use weak assertions like `expect(x).toBeTruthy()`
- ❌ **Claim "Ready for implementation" when tests are skipped**
- ❌ **Deviate from the test plan** (if plan seems wrong, ask first)

---

## When to Pause

Only pause and ask user for help when:
- Stuck on same error 3+ times for one test
- Test plan seems wrong or incomplete
- Missing information needed to write test
- Blocking infrastructure issue (test framework broken)

Do NOT pause for:
- Normal test failures (that's expected!)
- Moving to next test
- Minor decisions within test implementation

---

## Handoff

This skill hands off to:
- **`/implement-to-pass`** - Implements code to make all tests pass
