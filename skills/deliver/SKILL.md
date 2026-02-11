---
name: deliver
description: "Unified closure skill. Posts QA checklist, updates GitHub issue status, and links/merges PR. Terminal step of the workflow."
contract:
  tags: [closure, qa, github]
  state_source: spec
  inputs:
    params:
      - name: issue_number
        required: true
    gates:
      - field: "status"
        value: "Implemented"
  outputs:
    mutates: []
    side_effects: ["Posts QA checklist", "Sets status to QA", "Links PR"]
  next: []
  human_gate: false
---

# Deliver Phase

Unified closure and handoff. This skill extracts final manual verification steps for QA, updates the GitHub issue, links the PR, and ensures the project state reflects completion.

## Principles

1. **Actionable Checklists**: QA items should be observable actions ("Verify X" rather than just "X").
2. **State Synchronization**: The repo (active-context), the project board, and the issue must all stay in sync.
3. **Link Everything**: Ensure the PR, issue, and spec are cross-referenced for traceability.

## Todo Template

On invocation, create this todo list:

- [ ] **QA Preparation**
  - [ ] Extract manual-only criteria from spec
  - [ ] Format as QA testing checklist (Actionable checkboxes)
- [ ] **GitHub Update**
  - [ ] Get user confirmation for GitHub post
  - [ ] Post QA checklist comment to issue #{issue_number}
  - [ ] Link PR to issue
  - [ ] Update project board status to `QA` (or `Done` if immediate merge)
- [ ] **State Sync**
  - [ ] Update `active-context.md` (mark issue as delivered)
  - [ ] Remove any temporary branch references
- [ ] **Handoff**
  - [ ] Final summary of handoff status

## References
- `shared/github-ops.md`: GitHub CLI patterns
- `shared/spec-io.md`: Spec data extraction
