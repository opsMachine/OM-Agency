---
name: 4-security-fix
description: "Phase 4 of security audit pipeline. Implements the fix to pass the failing security test from Phase 3. Loops back to Phase 3 for the next item. Invoke with '/4-security-fix' after Phase 3 creates the failing test."
contract:
  tags: [security, audit, security-phase-4, implementation]
  state_source: security_plan
  inputs:
    params: []
    gates:
      - field: "current_item.test"
        value: "Written"
  outputs:
    mutates:
      - field: "current_item.status"
        sets_to: "DONE"
    side_effects: []
  next: [3-security-spec]
  human_gate: false
---

# Phase 4: Implementation & Verification

## What this phase does
Fix the vulnerability. Make the failing test pass. Mark the item done.

## Instructions

1. **Read** the failing test from Phase 3.

2. **Fix** the application code to address the vulnerability.
   - Run the test after each change
   - Iterate until it passes
   - Verify no other tests regressed

3. **Mark done.** Update `SECURITY_PLAN.md` — set this item's status to `DONE`.

> **End-of-skill check:** See `shared/primitive-updates.md`. Signals: architectural constraints, code that must not be refactored.

4. **Stop.** Report what was fixed.

If there are more `Pending` items in the backlog, loop back to Phase 3: `/3-security-spec`
Otherwise, the security audit is complete.
