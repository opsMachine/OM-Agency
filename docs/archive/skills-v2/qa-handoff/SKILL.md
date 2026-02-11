---
name: qa-handoff
description: "Update GitHub issue with testing checklist for QA testers. Use after implementation is complete, before merge. Invoke with '/qa-handoff #42 path/to/spec.md' or 'qa handoff', 'ready for testing', 'update issue for QA'."
contract:
  tags: [closure, qa, github]
  state_source: spec
  inputs:
    params:
      - name: issue_number
        required: true
      - name: spec_path
        required: true
    gates: []
  outputs:
    mutates: []
    side_effects: ["Posts QA checklist", "Sets status to QA", "Links PR"]
  next: []
  human_gate: false
---

# QA Handoff

Posts a testing checklist to a GitHub issue so QA testers have everything they need for manual verification. This is the final step before merge.

## When to Use

Use this skill when:
- Implementation is complete and verified
- PR is ready for review/merge
- QA testers need to know what to test manually
- User says "ready for testing", "qa handoff", or "update issue for QA"

## Prerequisites

Before using this skill:
1. Implementation must be complete
2. Automated tests must be passing
3. `/verification-before-completion` should have been run
4. PR should exist (or be ready to create)

## Instructions

### Step 1: Gather Inputs

Require two inputs from the user:
1. **Issue number** (e.g., `#42` or `42`)
2. **Spec document path** (e.g., `Documents/specs/42-dark-mode-spec.md`)

If not provided, ask:
- "What's the issue number?"
- "Where's the spec document?"

### Step 2: Read the Spec

Read the spec document to extract:
- Feature summary (from Problem Statement)
- Acceptance criteria (the testing checklist)
- Any specific test scenarios mentioned

> See shared/spec-io.md for spec sections and how to extract acceptance criteria.

### Step 3: Get PR Information

Check for an open PR linked to this work:

```bash
gh pr list --state open --head $(git branch --show-current)
```

If a PR exists, note its number. If not, note that PR creation is pending.

### Step 4: Format Testing Checklist

Convert acceptance criteria to a QA-friendly format:

1. **Use checkbox syntax** for trackable items
2. **Add context** where needed (not just the criterion)
3. **Include browser/device requirements** if applicable
4. **Note any test data needed**

Example transformation:

Spec criterion:
> - [ ] Toggle appears in Settings > Appearance

QA checklist item:
> - [ ] Navigate to Settings > Appearance. Verify dark mode toggle is visible.

### Step 5: Post to GitHub Issue

Create a comment on the issue with this structure:

```markdown
## Ready for QA Testing

**Status:** Implementation complete, ready for manual verification.

**Spec:** `{spec-path}` (see repo for full details)

**PR:** #{pr-number} (or "PR pending")

---

### Manual Testing Checklist

{Converted acceptance criteria as checkboxes}

---

### Test Environment
- Branch: `{current-branch}`
- Prerequisites: {any setup needed}

### Notes for Testers
{Any additional context, known limitations, or specific things to watch for}
```

> See shared/github-ops.md for posting the QA checklist comment.

### Step 6: Link PR to Issue (if applicable)

If a PR exists and isn't already linked, update the PR to reference the issue.

> See shared/github-ops.md for linking PR to issue.

### Step 7: Update Project Board Status

**MANDATORY:** Set the issue status to **QA** on the project board.

> See shared/github-ops.md for updating project board status.

> **End-of-skill check:** See `shared/primitive-updates.md`. Signals: decisions made during QA review.

### Step 8: Confirm Handoff

Tell the user:

"QA handoff complete:
- Testing checklist posted to issue #{number}
- Project board status set to QA
- PR #{pr-number} is ready for review
- QA testers can now verify the acceptance criteria

Next: Wait for QA sign-off, then merge."

## Example Output

For issue #42 with a dark mode spec:

```markdown
## Ready for QA Testing

**Status:** Implementation complete, ready for manual verification.

**Spec:** `Documents/specs/42-dark-mode-spec.md`

**PR:** #123

---

### Manual Testing Checklist

- [ ] Navigate to Settings > Appearance. Verify dark mode toggle is visible.
- [ ] Click the toggle. Verify the theme switches immediately without page reload.
- [ ] Refresh the page. Verify the dark mode preference persists.
- [ ] Test in Chrome and Firefox. Verify consistent behavior.
- [ ] Test with system set to light mode. Verify app respects user preference over system.

---

### Test Environment
- Branch: `feature/dark-mode`
- Prerequisites: None, works on any account

### Notes for Testers
- Toggle state is stored in localStorage, so clearing browser data will reset it.
- This does not include per-page theme customization (explicitly out of scope).
```

## Best Practices

1. **Make checklists actionable** - "Verify X appears" not just "X appears"
2. **Include navigation steps** - "Go to Settings > Appearance" not just "In settings"
3. **Note browser requirements** - If testing should happen in specific browsers
4. **Mention test data** - If QA needs specific accounts or data to test
5. **Keep it concise** - Link to spec for full details, don't duplicate everything

## Common Issues

**No PR exists yet:**
- Note "PR pending" in the comment
- Remind user to create PR and link it

**Issue already has testing info:**
- Add a new comment rather than editing old ones
- Reference the latest implementation state

**Spec has many criteria:**
- Group related criteria under subheadings
- Prioritize critical paths first
