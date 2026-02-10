---
name: 2-security-critique
description: "Phase 2 of security audit pipeline. Red team review of Phase 1 findings — removes false positives, adds missed risks, ranks the backlog. Invoke with '/2-security-critique' after Phase 1 is complete."
contract:
  tags: [security, audit, security-phase-2]
  state_source: security_plan
  inputs:
    params: []
    gates:
      - field: "findings"
        value: "Pending"
  outputs:
    mutates:
      - field: "backlog"
        sets_to: "Ranked"
    side_effects: []
  next: [3-security-spec]
  human_gate: true
---

# Phase 2: Red Team Critique

## What this phase does
Challenge every finding from Phase 1. Tighten the plan before any code is written.

## Instructions

1. **Read** `SECURITY_PLAN.md`. Review every `Pending` item.

2. **Critique:**
   - Remove false positives (flag anything that isn't actually exploitable)
   - Add missing risks (e.g. "You missed the rate limit check on this endpoint")
   - Rank the remaining items by exploitability and impact

3. **Output:** Update `SECURITY_PLAN.md` with a **Ranked Backlog**. Top item is what Phase 3 will target.

4. **Stop.** Present the ranked backlog to the user.

The next step is Phase 3: `/3-security-spec`
