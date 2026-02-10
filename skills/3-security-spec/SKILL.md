---
name: 3-security-spec
description: "Phase 3 of security audit pipeline. Writes a failing test that reproduces the top vulnerability from the ranked backlog. Invoke with '/3-security-spec' after Phase 2 is complete. Do NOT fix code — just write the test."
contract:
  tags: [security, audit, security-phase-3, tdd]
  state_source: security_plan
  inputs:
    params: []
    gates:
      - field: "backlog"
        value: "Ranked"
  outputs:
    mutates:
      - field: "current_item.test"
        sets_to: "Written"
    side_effects: ["Creates test file"]
  next: [4-security-fix]
  human_gate: false
---

# Phase 3: TDD Specification

## What this phase does
Write a failing test that proves the top vulnerability exists. This is the red phase — do not touch the application code.

## Instructions

1. **Read** `SECURITY_PLAN.md`. Pick the top `Pending` (not `DONE`) item from the ranked backlog.

2. **Write a test** that reproduces the vulnerability.
   - Create a new test file (e.g. `tests/security/exploit_repro.test.ts`)
   - The test should FAIL right now — it's proving the vulnerability exists
   - **Do NOT fix the code.** That's Phase 4.

3. **Run the test.** Confirm it fails for the right reason (the vulnerability, not a syntax error).

4. **Stop.** Report the test file path and what it proves.

The next step is Phase 4: `/4-security-fix`
