---
name: understand
description: "Unified requirements gathering and spec review. Use for new features, major changes, or when starting any task. Reads GitHub issue, conducts interview, assembles spec, and performs self-review in one pass."
contract:
  tags: [intake, requirements, spec-creation, review, quality-gate, github]
  state_source: spec
  inputs:
    params:
      - name: issue_number
        required: false
    gates: []
  outputs:
    mutates:
      - field: "status"
        sets_to: "Draft"
    side_effects: ["Creates/comments GitHub issue", "Adds to project board"]
  next: [test, build]
  human_gate: true
---

# Understand Phase

Unified requirements gathering and specification review. This skill guides the interview process to extract intent, assembles the spec, and performs an immediate self-review to ensure quality before presenting to the human for approval (Gate A).

## Principles

1. **Context is King**: Always start by reading the GitHub issue and existing relevant code.
2. **Done-State Definition**: If you can't describe how to verify it, you haven't understood the requirement.
3. **Assessable Criteria**: Write acceptance criteria as objective outcomes (✅ satisfied / ⚠️ unsure / ❌ not satisfied). Avoid "appropriately" or "properly".
4. **Security by Design**: Security isn't a checklist at the end; it's a constraint on the solution.
5. **Self-Correction**: Review your own spec for gaps (non-goals, edge cases) before reporting done.

## Todo Template

On invocation, create this todo list:

- [ ] **Context Intake**
  - [ ] Read issue #{issue_number} (if provided)
  - [ ] Search codebase for related patterns
- [ ] **Interview Phase**
  - [ ] Problem Statement: What, Why, Who?
  - [ ] Acceptance Criteria: Define observable done-states + Test Type (Unit/Integration/Manual)
  - [ ] Scope Fence: Define Non-Goals (at least 1 exclusion)
  - [ ] Security Considerations: Data sensitivity, Auth, RLS, Input validation
  - [ ] Constraints & Assumptions: Dependencies, technical limits
- [ ] **Spec Assembly**
  - [ ] Resolve any remaining open questions
  - [ ] Create/Update spec at `Documents/specs/{issue}-{slug}-spec.md`
  - [ ] Create/Update GitHub issue + set project status
- [ ] **Self-Review (Quality Gate)**
  - [ ] REVIEW: Criteria are assessable (not vague)
  - [ ] REVIEW: Non-goals are explicit
  - [ ] REVIEW: Security sections are meaningful (not generic)
  - [ ] REVIEW: No open questions remain
- [ ] **Handoff**
  - [ ] Propose mode: **Lightweight** (UI/Simple CRUD) or **Structured** (High-risk/Complex)
  - [ ] Present spec + assessment → **Gate A: Human Approval**

## References
- `shared/spec-io.md`: Spec structure and I/O
- `shared/github-ops.md`: GitHub CLI patterns
- `shared/security-lens.md`: Security thinking patterns
