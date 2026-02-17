# Testing Standards

Verification and quality control patterns for implementation work. Referenced by `implement-direct`, `implement-to-pass`, and the workflow manager.

---

## Core Principle

**"Done" means: built + tested + verified + QA-ready**

Not just "the code compiles" or "I think it works." Every implementation must be:
1. Functionally verified (you ran it and confirmed it works)
2. Edge cases tested (you tried to break it)
3. Documented for QA (clear instructions on what to test)

---

## Definition of Done

Before marking any work as complete:

### 1. Automated Tests Pass
- Run the full test suite: `npm test` (or project-specific command)
- All existing tests still pass (no regressions)
- New tests added for the feature/fix (if applicable)
- **No skipping this step**, even for "small changes"

### 2. Manual Verification Complete
Test the actual feature in the running application:

**Happy Path:**
- Primary user flow works as specified
- UI renders correctly (no console errors)
- Data persists properly
- Success states display correctly

**Error Cases:**
- Invalid input handled gracefully
- Network errors don't crash the app
- Error messages are clear and helpful
- Failed states display correctly

**Edge Cases:**
- Test the falsification scenarios from the spec (if present)
- Try boundary values (empty strings, max lengths, special characters)
- Test concurrent operations (if relevant)
- Test different user roles/permissions (if relevant)

### 3. Documentation for QA
Provide clear testing instructions using the [QA Handoff Template](#qa-handoff-template) below.

---

## Quick Fix Protocol

**Never deploy a "quick fix" without full verification.**

Quick fixes are the highest whack-a-mole risk. They feel small and safe, but they're where regressions hide.

### Before deploying ANY fix:
1. Run the full test suite (catches regressions)
2. Manually test the happy path (ensures fix works)
3. Manually test the thing you just fixed (confirms it's actually fixed)
4. Check for console errors (JavaScript errors hide here)
5. Add a test for the bug you just fixed (prevents it coming back)

### If you skip these steps:
- You will create new bugs
- QA will catch them (wasting time)
- Or worse, clients will catch them (eroding trust)

**No shortcuts. Ever.**

---

## QA Handoff Template

When handing off to QA, provide these details. Copy this template and fill it in:

```markdown
## QA Handoff: {Feature Name}

**Staging Environment:**
- URL: {staging link}
- Credentials: {if needed}
- Branch: {git branch name}

**What Changed:**
{Brief summary of what was built/fixed}

**Happy Path Test:**
1. {Step-by-step instructions}
2. {Expected result at each step}
3. {Final success state}

**Edge Cases to Verify:**
From falsification analysis (if present in spec):
- [ ] {Edge case 1 from spec}
- [ ] {Edge case 2 from spec}
- [ ] {Edge case 3 from spec}

Additional edge cases:
- [ ] Invalid input handling
- [ ] Empty states
- [ ] Error conditions
- [ ] Boundary values

**Expected Behavior:**
- ✅ {What should work}
- ✅ {What should work}
- ❌ {What should NOT happen}

**Known Limitations:**
{Anything not implemented or explicitly out of scope}

**Verification Checklist:**
- [ ] No console errors
- [ ] UI renders correctly on desktop
- [ ] UI renders correctly on mobile (if relevant)
- [ ] Data persists after refresh
- [ ] Error states display properly
- [ ] Loading states work correctly
```

---

## Smoke Test Guidelines

When automated tests are insufficient or painful to maintain, use smoke tests: quick manual verification checklists for critical flows.

### Creating a Smoke Test Checklist

1. **Identify critical paths** - The 3-5 flows that MUST work for the app to be functional
2. **Document steps** - Clear, numbered steps anyone can follow
3. **Keep it short** - Each smoke test should take < 5 minutes
4. **Store in project** - Keep in `SMOKE_TESTS.md` or similar

### Example Smoke Test

```markdown
## Quote Creation Flow (2 min)
1. Navigate to /quotes/new
2. Select service type: "Testament"
3. Fill client name: "Test Client"
4. Submit form
5. ✅ Quote appears in list
6. ✅ Email sent (check logs)
7. ✅ No console errors
```

### When to Use Smoke Tests

- Before every demo to client
- After deploying to staging
- Before marking feature "done"
- After fixing bugs (to prevent regressions)

**Smoke tests are NOT a replacement for automated tests.** They're a safety net when automation is incomplete.

---

## Screen Recording Protocol

When handing off to QA, consider recording a quick video of your testing:

**Why this helps:**
- Shows QA what to expect
- Acts as proof you tested
- Helps document complex flows
- Useful for async communication

**How to do it:**
1. Open screen recorder (Loom, QuickTime, OBS)
2. Narrate what you're testing as you do it
3. Show happy path + 1-2 edge cases
4. Keep it under 5 minutes
5. Send link to QA with handoff

**Optional, not required** - but helpful for complex features or when QA is new to the project.

---

## Common Pitfalls to Avoid

### ❌ "I tested in dev, it works"
- Dev environment might have different data
- Build process might behave differently
- Always test in staging before calling it done

### ❌ "The tests pass, we're good"
- Automated tests might not cover the actual bug
- Tests might be outdated or wrong
- Always manually verify in the app

### ❌ "Just needs one small tweak"
- Small tweaks still need full verification
- "One small tweak" often breaks something else
- Follow the Quick Fix Protocol

### ❌ "QA will catch it"
- QA is the last line of defense, not the first
- Your job is to deliver QA-ready work
- QA should be verifying, not debugging

---

## Integration with Workflow

This document is referenced by:
- **workflow-router** - Passes testing requirements to all implementation sub-agents
- **implement-direct** - Must follow before marking work complete
- **implement-to-pass** - Must follow before marking work complete
- **qa-handoff** - Uses the QA Handoff Template

When dispatched as a sub-agent, implementation skills must:
1. Read this document before reporting done
2. Follow the Definition of Done
3. Document what was tested (include in completion report)
4. Flag anything that couldn't be verified

---

## Questions?

If you're unsure whether something needs testing:
- **Ask yourself:** "If this breaks in production, what's the impact?"
- **High impact** = comprehensive testing required
- **Low impact** = smoke test at minimum
- **No impact** = you're probably missing something

When in doubt, test more, not less.
