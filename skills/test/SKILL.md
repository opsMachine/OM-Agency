---
name: test
description: "Unified test planning and writing. Use for Structured Mode features or when TDD is required. Creates test plan in spec and writes failing tests."
contract:
  tags: [tdd, testing, red-phase, test-planning]
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
      - field: "Test Plan.status"
        sets_to: "Tests Written"
    side_effects: []
  next: [build]
  human_gate: false
---

# Test Phase

Unified test planning and writing. This skill identifies the required test coverage, plans the locations (expand vs create), and implements the failing tests that define the done-state.

## Principles

1. **Analytical Planning**: Identify coverage needs (unit/integration/E2E) before writing code.
2. **Expand before Create**: Add to existing test files whenever possible to maintain cohesion.
3. **Test Behaviors, not Criteria**: Multiple criteria can often be verified in a single test flow.
4. **Isolated Context**: This skill typically runs in a sub-agent to ensure implementation details don't leak into the design phase.
5. **Fail Loudly & Correctly**: A test must fail for the right reason (feature missing), never due to infrastructure issues.

## Todo Template

On invocation, create this todo list:

- [ ] **Test Planning**
  - [ ] Read approved spec and criteria
  - [ ] Search for existing related tests
  - [ ] Map criteria to test files (Expand vs Create)
  - [ ] Add `## Test Plan` section to spec with status `Planned`
- [ ] **Infrastructure Check**
  - [ ] Verify test runner and required services (Docker/Supabase) are active
- [ ] **Test Implementation**
  - [ ] Write failing test for Criterion #1
  - [ ] Verify TEST #1 FAILS for the right reason
  - [ ] Write failing test for Criterion #2
  - [ ] Verify TEST #2 FAILS
  - [ ] ... (repeat for all testable criteria)
- [ ] **Self-Review**
  - [ ] REVIEW: No tautological tests (assert true)
  - [ ] REVIEW: No weak assertions (toBeTruthy)
  - [ ] REVIEW: Manual-only criteria listed for QA
- [ ] **Handoff**
  - [ ] Update spec Test Plan status to `Tests Written`
  - [ ] Report: test files, failure reasons, and manual criteria list

## References
- `shared/test-planning.md`: Granularity and grouping framework
- `shared/e2e-patterns.md`: E2E and Playwright patterns
- `shared/spec-io.md`: Spec structure
