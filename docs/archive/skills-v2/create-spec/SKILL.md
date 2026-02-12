---
name: interview
description: "Structured requirements gathering for new features or changes. Use when starting work on a feature, beginning a new task, or when the user says 'interview', 'start work on', 'new feature', or 'requirements'. Reads GitHub issue for context, outputs spec to Documents/specs/, updates issue with summary."
contract:
  tags: [intake, requirements, spec-creation, github]
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
  next: [spec-review]
  human_gate: false
---

# Interview

Structured requirements gathering that produces a specification document. This skill guides a conversational interview to fully extract and understand what needs to be built before any implementation begins.

## When to Use

Use this skill when:
- Starting work on a new feature or change
- User mentions an issue number they want to work on
- User says "interview me", "let's start", "new feature", or "requirements"
- Beginning any non-trivial implementation task

## Instructions

### Step 1: Issue Intake (if applicable)

If the user provides a GitHub issue number:

1. Fetch the issue using `gh issue view {number}`
2. Extract title and description as seed context
3. Acknowledge: "I've read issue #{number}: {title}. Let me ask some questions to fully understand what we're building."

If no issue number, proceed directly to interview.

### Step 2: Problem Framing

Ask these questions (adapt based on context):

1. **What problem are we solving?**
   - Get the core problem in 1-2 sentences
   - If vague, ask "Can you give me a concrete example of when this problem occurs?"

2. **Why does this matter now?**
   - Understand urgency and priority
   - "What happens if we don't solve this?"

3. **Who benefits?**
   - Identify the user/persona affected
   - "Who will use this feature?"

Capture responses in the Problem Statement section.

### Step 3: Requirements Extraction

Ask these questions:

1. **What does "done" look like?**
   - Get specific, observable outcomes
   - "If this worked perfectly, what would a user see/experience?"

2. **How would we test that?**
   - Convert outcomes to testable criteria
   - "How would we verify this is working correctly?"

3. **Are there edge cases to consider?**
   - Boundary conditions, error states
   - "What should happen if X fails or Y is empty?"

4. **Classify each criterion by Test Type:**
   - **Unit** - Can test with isolated code, mocks OK
   - **Integration** - Requires real DB/services (edge functions, DB tests)
   - **Manual** - Cannot automate (external APIs, visual, UX) → QA checklist

   Ask: "For [criterion], can we write an automated test, or is this something QA verifies manually?"

**Write criteria that are assessable, not just testable.** An implementer should be able to objectively determine whether each criterion is satisfied. Avoid vague phrasing like "handles errors appropriately" — instead say what should happen: "Returns 400 with message 'Email required' when email field is empty."

Capture as Acceptance Criteria table with Test Type column. Example:

| # | Criterion | Test Type |
|---|-----------|-----------|
| 1 | API returns 400 if replyTo missing | Unit |
| 2 | Email sent via Graph API includes header | Manual |

### Step 4: Scope Fencing

Ask these questions:

1. **What are we NOT doing?**
   - Explicit exclusions prevent gold-plating
   - "Is there anything related that we should explicitly leave out?"

2. **What's out of scope for this iteration?**
   - Future work vs. current work
   - "Any nice-to-haves we should defer?"

Capture in Non-Goals section.

### Step 5: Security Considerations

Ask these questions:

1. **Does this feature handle sensitive data?**
   - User PII, credentials, financial data, tokens
   - "What data does this feature read, write, or expose?"

2. **What authentication/authorization is needed?**
   - Who should be able to access this?
   - "Should this be admin-only, user-specific, or public?"

3. **Are there input validation concerns?**
   - User-provided data that reaches the database or is displayed
   - "What user input does this accept? Where does it go?"

4. **Any RLS/database security implications?** (for Supabase projects)
   - New tables need RLS policies
   - Existing RLS policies may need updates
   - "Does this add or modify database access patterns?"

Capture in Security Considerations section.

**Common security flags to watch for:**
- New API endpoints → need auth checks
- User input displayed → XSS risk
- User input in queries → injection risk
- File uploads → validation needed
- New database tables → RLS policies required
- Service role usage → minimize exposure

### Step 6: Constraints & Assumptions

Ask these questions:

1. **Any technical constraints?**
   - Existing patterns to follow, libraries to use, performance requirements

2. **Dependencies?**
   - Does this depend on or block other work?

3. **What are we assuming?**
   - Make implicit assumptions explicit
   - "Are we assuming the user is already logged in?"

Capture in Assumptions & Constraints section.

### Step 7: Resolve Open Questions

Review what you've gathered and ask:

1. **Anything unclear that we should clarify now?**
2. **Any decisions we need to make before starting?**

Document resolved questions.

### Step 8: Assemble Specification

1. Create the spec file at `Documents/specs/{issue-number}-{slug}-spec.md`
   - If no issue number, use a descriptive slug
   - Example: `Documents/specs/42-dark-mode-spec.md`

2. Use the template from `Documents/templates/spec-template.md`

3. Fill in all sections from the interview:
   - Problem Statement
   - Acceptance Criteria (as checkboxes)
   - Non-Goals
   - Security Considerations
   - Assumptions & Constraints
   - Technical Notes
   - Open Questions Resolved

4. Set Status to "Draft"

### Step 9: Create/Update GitHub Issue

**If no issue exists yet, create one.** If working from an existing issue, post a comment with the spec summary.

> See shared/github-ops.md for issue creation and posting comments.

**After creating/updating the issue:**

1. **Link issue to spec** - Add `**Issue:** #{number}` to the spec header

Spec stays as `Draft` until human approves after spec-review.


### Step 9.5: Add Issue to Project (MANDATORY)

**Every issue MUST be added to the project board.** No exceptions.

1. **Find the project number:**
   - Check project's `CLAUDE.md` for `Project Number:` in GitHub Config
   - If not documented, ask the user
   - **Document it** in the project's `CLAUDE.md` for future:
     ```markdown
     ## GitHub Config
     - **Project Number:** {number}
     ```

2. **Add the issue to the project and set status.**

> See shared/github-ops.md for adding to project and setting status.

3. **Ask iteration and status:**
   > "Which iteration and status?"
   > - Backlog (not scheduled yet)
   > - Ready (scheduled, waiting to start)
   > - In Progress (starting now)

**Fallback:** If project board operations fail, provide manual instructions:
"Please add issue #{number} to the project board and set it to {status}."


> **End-of-skill check:** See `shared/primitive-updates.md`. Signals: domain terms or acronyms surfaced during requirements.

### Step 10: Handoff

Tell the user:

"Spec is at `Documents/specs/{filename}`. Review it, then:

`/spec-review Documents/specs/{filename}`

That will flag any gaps. Once you approve, we pick TDD or direct implementation."

## Interview Checklist

Use this to track coverage:

- [ ] Problem Statement: Clear problem defined
- [ ] Problem Statement: Why it matters explained
- [ ] Problem Statement: Who benefits identified
- [ ] Acceptance Criteria: At least 3 testable criteria
- [ ] Acceptance Criteria: Edge cases considered
- [ ] Acceptance Criteria: **Each criterion has Test Type (Unit/Integration/Manual)**
- [ ] Non-Goals: At least 1 explicit exclusion
- [ ] Security: Data sensitivity assessed
- [ ] Security: Auth/authz requirements defined
- [ ] Security: Input validation needs identified
- [ ] Assumptions: Key assumptions documented
- [ ] Constraints: Technical constraints noted
- [ ] Open Questions: All questions resolved
- [ ] **GitHub: Issue added to project board**
- [ ] **GitHub: Sprint status set (Backlog/Current/Next)**

## Best Practices

1. **Don't rush** - Better to ask one more question than miss a requirement
2. **Use concrete examples** - If something is vague, ask for an example
3. **Read back summaries** - "So if I understand correctly..." to verify
4. **Challenge assumptions** - "Why do we need X?" can reveal unnecessary scope
5. **Keep it conversational** - This is a dialogue, not an interrogation

## Example

User: "I want to start work on issue #42"

Claude:
1. Runs `gh issue view 42` to get context
2. "I've read issue #42: Add dark mode toggle. Let me ask some questions..."
3. Proceeds through interview phases
4. Creates `Documents/specs/42-dark-mode-spec.md`
5. Posts summary comment to issue #42
6. Adds to project, asks about iteration
7. Tells user next steps
