# GitHub Conventions

Central reference for GitHub operations across all skills. Skills should follow these patterns for consistency.

---

## Per-Project Configuration

Each project's `CLAUDE.md` should include:

```markdown
## GitHub Config

- **Repo:** owner/repo-name
- **Project Number:** 1 (or your project board number)
- **Bug Template:** bug (or your bug template name)
- **Default Labels:** [optional, e.g., "needs-triage"]
```

If not specified, discover dynamically:
```bash
# Get repo info from current directory
gh repo view --json owner,name

# List projects to find the main one
gh project list --owner {owner} --limit 5
```

---

## When to Use `gh` CLI vs MCP

**Always prefer `gh` CLI** for:
- Reading issues/PRs: `gh issue view`, `gh pr view`
- Creating issues/PRs: `gh issue create`, `gh pr create`
- Posting comments: `gh issue comment`, `gh pr comment`
- Editing: `gh issue edit`, `gh pr edit`
- Project operations: `gh project item-add`, `gh project item-edit`

**Use MCP tools** when:
- `gh` CLI doesn't support the operation
- Bulk operations that benefit from API batching
- Complex queries not supported by `gh`

**Rationale:** `gh` CLI is more familiar, better error messages, works offline for some operations, and avoids MCP auth complexity.

---

## Issue Creation

### Feature Issues

```bash
gh issue create \
  --title "feat: {short description}" \
  --body "## Problem
{what problem this solves}

## Proposed Solution
{brief approach}

## Acceptance Criteria
- [ ] {criterion 1}
- [ ] {criterion 2}
"
```

### Bug Issues

**Always use the bug type (not label):**

```bash
gh issue create \
  --title "bug: {short description}" \
  --type bug
```

For additional context, include a body:

```bash
gh issue create \
  --title "bug: {short description}" \
  --body "## Description
{what's happening}

## Expected Behavior
{what should happen}

## Steps to Reproduce
1. {step 1}
2. {step 2}

## Environment
- Browser/OS:
- User type:
"
```

---

## Project Board Integration

**MANDATORY:** Every issue must be added to the project board. No exceptions.

### Finding the Project Number

1. **Check project's CLAUDE.md first** for `Project Number:` in GitHub Config section
2. **If not documented**, discover it:
   ```bash
   gh project list --owner {owner} --limit 5
   ```
3. **If multiple projects or unclear**, ask the user:
   > "Which project should issues go to? I found: [list projects]"
4. **Document for future:** Add to the project's CLAUDE.md:
   ```markdown
   ## GitHub Config
   - **Project Number:** {number}
   ```

### Adding Issues to Project

```bash
# Add issue to project (REQUIRED for every issue)
gh project item-add {project-number} --owner {owner} --url {issue-url}
```

**Then ask about iteration:**

> "Which iteration should this go in?"
> - Current Sprint
> - Next Sprint
> - Backlog

```bash
# Get the item ID (needed for field updates)
gh project item-list {project-number} --owner {owner} --format json --jq '.items[] | select(.content.number == {issue-number}) | .id'

# Set iteration (if user specified)
gh project field-list {project-number} --owner {owner} --format json
```

**Fallback:** If `gh project` commands fail, provide manual instructions:
"Please add issue #{number} to the project board and set iteration to {sprint}."

---

## Status Workflow

**MANDATORY:** Always set status when creating or updating issues.

### Status Values

| Status | When to Set |
|--------|-------------|
| **Backlog** | New issue, not yet scheduled |
| **Ready** | Spec approved, waiting to start |
| **In Progress** | Currently being implemented |
| **In Review** | PR open, awaiting review |
| **QA** | Implementation done, needs manual testing |
| **Done** | Merged and verified |

### When to Set Status

| Action | Set Status To |
|--------|---------------|
| `/interview` creates issue | Ask: Backlog, Ready, or In Progress |
| Starting implementation | In Progress |
| PR created | In Review |
| `/qa-handoff` | QA |
| Merged & verified | Done |

### Updating Status

```bash
# Get project field info (do this once per project, cache the IDs)
gh project field-list {project-number} --owner {owner} --format json

# Update status
gh project item-edit \
  --project-id {project-id} \
  --id {item-id} \
  --field-id {status-field-id} \
  --single-select-option-id {status-option-id}
```

**Fallback:** If field IDs are complex, tell the user:
"Please set issue #{number} status to {status} on the project board."

---

## Posting Updates to Issues

### Format for Implementation Notes

```markdown
## Implementation Update

**Status:** {In Progress | Complete | Blocked}

### Changes Made
- `{file1}` - {what changed}
- `{file2}` - {what changed}

### Decisions
- {any decisions made during implementation}

### Next Steps
{what happens next, or "Ready for QA"}
```

### Format for Diagnosis Notes

```markdown
## Diagnosis

**Root Cause:** {one-line summary}
**Location:** `{file:line}`
**Severity:** {Critical | High | Medium | Low}

### Details
{explanation of what's happening}

### Proposed Fix
{approach}

Ready for fix.
```

---

## Confirmation Prompts

**Before posting to GitHub, always confirm:**

> "Ready to update GitHub issue #{number}:
> - Post implementation notes
> - Set status to {status}
>
> Proceed?"

This gives user control over when/what gets posted.

---

## Types vs Labels

**Types** are built-in GitHub issue categories. Use `--type` when creating:
- `bug` - Bug reports
- `feature` - New features (some repos use this)

```bash
gh issue create --title "bug: description" --type bug
```

**Labels** are custom tags for filtering/organizing. Add with `--add-label`:

| Label | When to Use |
|-------|-------------|
| `security` | Security-related |
| `blocked` | Waiting on something |
| `documentation` | Docs changes |
| `priority:high` | Urgent issues |

```bash
gh issue edit {number} --add-label "security,priority:high"
```

---

## Linking PRs to Issues

Always link PRs to their issue for automatic closing:

```bash
# In PR body, include:
Closes #{issue-number}
# or
Fixes #{issue-number}
```

Or update existing PR:
```bash
gh pr edit {pr-number} --body "Closes #{issue-number}

{rest of PR body}"
```

---

## Error Handling

If GitHub operations fail:

1. **Auth issues:** Check `gh auth status`
2. **Permission issues:** User may need to grant access
3. **Rate limits:** Wait and retry, or provide manual instructions
4. **Project API issues:** Fall back to manual instructions

**Always provide fallback instructions** rather than failing silently.
