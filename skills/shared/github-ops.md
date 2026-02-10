# GitHub Operations — Shared Reference

Single source of truth for all `gh` CLI patterns used across skills. When a skill needs to post a comment, update a status, or touch the project board, it references this file rather than re-implementing the pattern.

**Preference:** Always use `gh` CLI. Fall back to MCP only when `gh` doesn't support the operation.

---

## 1. Confirm Before Posting

Every GitHub write operation requires user confirmation first. No exceptions.

Pattern:
```
> Ready to update GitHub issue #{number}?
> - [what will be posted/changed]
> - [status change if any]
>
> Proceed?
```

Wait for explicit confirmation before running any `gh` write command.

---

## 2. Post Comment to Issue

```bash
gh issue comment {number} --body "## {Section Header}

{body content}
"
```

**Comment templates by context:**

### Implementation Notes
```bash
gh issue comment {number} --body "## Implementation Update

**Status:** {In Progress | Complete | Blocked}

### Changes Made
- \`{file1}\` - {what changed}
- \`{file2}\` - {what changed}

### Decisions
- {any decisions made}

### Next Steps
{what happens next}
"
```

### Diagnosis Notes
```bash
gh issue comment {number} --body "## Diagnosis

**Root Cause:** {one-line summary}
**Location:** \`{file:line}\`
**Severity:** {Critical | High | Medium | Low}

### Details
{explanation}

### Proposed Fix
{approach}
"
```

### QA Testing Checklist
```bash
gh issue comment {number} --body "## Ready for QA Testing

**Status:** Implementation complete, ready for manual verification.

**Spec:** \`{spec-path}\`

**PR:** #{pr-number} (or 'PR pending')

---

### Manual Testing Checklist

{acceptance criteria converted to actionable steps as checkboxes}

---

### Test Environment
- Branch: \`{current-branch}\`
- Prerequisites: {any setup needed}

### Notes for Testers
{additional context, known limitations}
"
```

---

## 3. Find Project Config

Check in order:

1. **Project's AGENTS.md** — look for `Project Number:` in a GitHub Config section
2. **Discover dynamically:**
   ```bash
   gh repo view --json owner,name
   gh project list --owner {owner} --limit 5
   ```
3. **If unclear:** Ask the user which project
4. **Document for future** — add to project's AGENTS.md under `## GitHub Config`:
   ```markdown
   ## GitHub Config
   - **Org:** {org}
   - **Project Number:** {number}
   ```

---

## 4. Add Issue to Project Board

**MANDATORY for every new issue.** No exceptions.

```bash
# Add issue to project
gh project item-add {project-number} --owner {owner} --url {issue-url}
```

Then ask the user about iteration:
> "Which iteration should this go in?"
> - Current Sprint
> - Next Sprint
> - Backlog

---

## 5. Update Project Board Status

**Status values:** Backlog → Ready → In Progress → In Review → QA → Done

```bash
# Step 1: Get item ID
gh project item-list {project-number} --owner {owner} --format json --jq '.items[] | select(.content.number == {issue-number}) | .id'

# Step 2: Get field IDs (do once per project, cache)
gh project field-list {project-number} --owner {owner} --format json

# Step 3: Set status
gh project item-edit \
  --project-id {project-id} \
  --id {item-id} \
  --field-id {status-field-id} \
  --single-select-option-id {status-option-id}
```

### When to set which status

| Action | Set status to |
|--------|---------------|
| Interview creates issue | Ask user: Backlog, Ready, or In Progress |
| Starting implementation | In Progress |
| PR created | In Review |
| QA handoff | QA |
| Merged & verified | Done |
| Diagnose completes | Ready (if not already set) |

---

## 6. Create Issue

### Feature
```bash
gh issue create \
  --title "feat: {short description}" \
  --body "## Problem
{what problem this solves}

## Acceptance Criteria
- [ ] {criterion 1}
- [ ] {criterion 2}
"
```

### Bug
```bash
gh issue create \
  --title "bug: {short description}" \
  --type bug \
  --body "## Description
{what's happening}

## Expected Behavior
{what should happen}

## Steps to Reproduce
1. {step 1}
2. {step 2}
"
```

---

## 7. Link PR to Issue

In PR body, include:
```
Closes #{issue-number}
```

Or update an existing PR:
```bash
gh pr edit {pr-number} --body "Closes #{issue-number}

{rest of body}"
```

---

## 8. Error Handling

If any `gh` command fails:

1. **Auth:** Check `gh auth status`
2. **Permissions:** User may need to grant access
3. **Rate limits:** Wait and retry
4. **Project API failures:** Fall back to manual instructions:
   > "Please [action] issue #{number} on the project board manually."

**Never fail silently.** Always surface the error and provide the manual fallback.

---

## 9. Querying Projects V2 (Custom Fields & Status)

The standard Issues API (`gh issue list`, MCP tools) cannot filter by project status columns or custom fields like Priority, Bug Severity, or Size. These live in the **Projects V2 API** (GraphQL only).

### When to Use

- Filter issues by project board status (e.g. "To Fix", "In progress")
- Filter by custom fields (Bug Severity, Priority, Size)
- Get all items in a specific project state
- Query iteration/sprint assignments

### Prerequisites

Check the project's AGENTS.md for a `## GitHub Config` section with org name, project number, and custom field names/values. If it doesn't exist yet, discover it (see [Discovering Project Config](#discovering-project-config) below).

### GraphQL Query Template

```graphql
query($owner: String!, $number: Int!, $after: String) {
  organization(login: $owner) {
    projectV2(number: $number) {
      items(first: 100, after: $after) {
        nodes {
          content {
            __typename
            ... on Issue { number title url labels(first: 10) { nodes { name } } }
          }
          fieldValues(first: 20) {
            nodes {
              __typename
              ... on ProjectV2ItemFieldSingleSelectValue {
                field { ... on ProjectV2SingleSelectField { name } }
                name
              }
            }
          }
        }
        pageInfo { hasNextPage endCursor }
      }
    }
  }
}
```

For user-owned projects, replace `organization(login:)` with `user(login:)`.

### Critical Gotchas

**1. Union types require inline fragments:**
```graphql
# CORRECT
field { ... on ProjectV2SingleSelectField { name } }

# WRONG — error: "Selections can't be made directly on unions"
field { name }
```

**2. Always request `__typename` on `content`:**
```graphql
# CORRECT
content { __typename ... on Issue { number title } }

# WRONG — content.__typename is undefined, breaks Issue vs DraftIssue filtering
content { ... on Issue { number title } }
```

**3. Always paginate:**
Loop with `after: endCursor` until `hasNextPage` is false. Boards can have 100+ items.

### Extracting Field Values

```javascript
function getFieldValue(fieldValues, fieldName) {
  if (!fieldValues?.nodes) return null;
  const node = fieldValues.nodes.find(
    (n) => n && n.field && n.field.name === fieldName
  );
  return node ? node.name : null;
}
```

### Emoji in Field Values

Custom fields often use emoji prefixes (e.g. "🔴 Critical", "🟠 Major"). Use `.endsWith('Critical')` for robust matching:

```javascript
const isCritical = severity === '🔴 Critical' || severity?.endsWith('Critical');
```

### Running with gh CLI

```bash
# Save query to file, then run with variables:
gh api graphql -F query=@query.graphql -f owner={org} -F number={project-number}

# For pagination, pass endCursor from previous response:
gh api graphql -F query=@query.graphql -f owner={org} -F number={project-number} -f after={endCursor}
```

### Discovering Project Config

When a project's AGENTS.md doesn't have GitHub Config yet, discover it:

```bash
# 1. Get org name
gh repo view --json owner,name

# 2. Get project number
gh project list --owner {org} --limit 5

# 3. Get all fields with their options
gh project field-list {number} --owner {org} --format json
```

**After discovery, document in the project's AGENTS.md** under `## GitHub Config` so future sessions don't repeat the work. Include:
- Org name
- Project number
- Each custom Single Select field with its option values (including emoji if present)

### Field Types Reference

| GraphQL Fragment | Field Type | Example |
|-----------------|------------|---------|
| `ProjectV2ItemFieldSingleSelectValue` | Single Select | Status, Priority |
| `ProjectV2ItemFieldTextValue` | Text | Any string |
| `ProjectV2ItemFieldNumberValue` | Number | 42 |
| `ProjectV2ItemFieldDateValue` | Date | "2026-02-07" |
| `ProjectV2ItemFieldIterationValue` | Iteration | Sprint object |
