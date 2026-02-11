---
name: build
description: "Unified implementation skill. Supports TDD (Green phase) and Direct implementation. Implements feature from spec and performs mandatory satisfaction assessment."
contract:
  tags: [implementation, green-phase, direct]
  state_source: spec
  inputs:
    params:
      - name: mode
        required: false
        values: ["tdd", "direct"]
    gates:
      - field: "status"
        value: "Approved"
  outputs:
    mutates:
      - field: "status"
        sets_to: "Implemented"
    side_effects: []
  next: [deliver]
  human_gate: true
---

# Build Phase

Unified implementation and verification. This skill produces the code needed to satisfy the spec, either by making failing tests pass (TDD) or by direct implementation using judgment.

## Principles

1. **Minimum Viable Code**: Implement only what is needed to satisfy the spec/tests. No gold-plating.
2. **Conventions over Invention**: Match existing patterns and styles in the codebase.
3. **Judgment-Led (Direct Mode)**: If a requirement seems wrong or ambiguous, ASK. Don't blindly implement bad design.
4. **End-to-End Verification**: Passing unit tests are not enough. Verify at least one criterion manually or end-to-end.
5. **Honest Assessment**: Use the satisfaction assessment (✅/⚠️/❌) to signal certainty to the user.

## Todo Template

On invocation, create this todo list:

- [ ] **Preparation**
  - [ ] Read spec acceptance criteria
  - [ ] Identify existing patterns in affected modules
- [ ] **Implementation**
  - [ ] {Mode dependent tasks: pass failing tests OR implement criteria sequentially}
- [ ] **Verification**
  - [ ] Build/Compile succeeds with no errors
  - [ ] Run test suite (if TDD) — all tests pass
  - [ ] Perform end-to-end check of at least one criterion
- [ ] **Satisfaction Assessment (Mandatory)**
  - [ ] VERIFY criterion #1: "{exact text}" → ✅/⚠️/❌
  - [ ] VERIFY criterion #2: "{exact text}" → ✅/⚠️/❌
  - [ ] ... (one per criterion)
  - [ ] VERIFY security: RLS/auth/input/secrets check
  - [ ] Flag any ⚠️ or ❌ items with explanation
- [ ] **Handoff**
  - [ ] Update spec status to `Implemented`
  - [ ] Present satisfaction assessment → **Gate B: Human Approval**

## References
- `shared/security-lens.md`: Implementation-time security patterns
- `shared/spec-io.md`: Spec status updates
- `shared/primitive-updates.md`: Post-implementation primitive check
