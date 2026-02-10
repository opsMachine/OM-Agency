---
name: spec-review
description: "Review a spec document for completeness before approval. Use after interview, before implementation, or when asked to 'review spec', 'check spec', or 'is this spec ready'. Read-only analysis that flags gaps."
allowed-tools: Read, Grep, Glob
contract:
  tags: [intake, review, quality-gate]
  state_source: spec
  inputs:
    params:
      - name: spec_path
        required: true
    gates:
      - field: "status"
        value: "Draft"
  outputs:
    mutates: []
    side_effects: []
  next: [plan-tests, implement-direct]
  human_gate: true
---

# Spec Review

Reviews a specification document for completeness and quality before approval. This is a read-only skill that analyzes without modifying.

## When to Use

Use this skill when:
- After an interview, before approving a spec
- User asks "is this spec ready?" or "review the spec"
- User invokes `/spec-review path/to/spec.md`
- Before starting implementation to verify spec quality

## Instructions

### Step 1: Read the Spec

Read the spec document at the path provided by the user.

> See shared/spec-io.md for spec file location and section structure.

If no path provided, look for recent specs in `Documents/specs/` and ask which one to review.

**Gate check:** Verify `**Status:**` is `Draft`. If already `Approved`, the spec has been reviewed — nothing to do here.

### Step 2: Check Completeness

Evaluate each section against these criteria:

#### Problem Statement
- [ ] Clearly states what problem is being solved
- [ ] Explains why it matters (impact/urgency)
- [ ] Identifies who benefits (user/persona)

**Red flags:**
- Vague statements like "improve the system"
- No clear user or beneficiary
- Missing "why"

#### Acceptance Criteria
- [ ] At least 3 testable criteria
- [ ] Each criterion is specific and observable
- [ ] Edge cases are covered
- [ ] Criteria use checkbox format
- [ ] Each criterion is **assessable** — an implementer can objectively determine ✅ satisfied / ⚠️ unsure / ❌ not satisfied

**Red flags:**
- Fewer than 3 criteria
- Vague criteria like "works well" or "is fast"
- No error/edge case handling
- Criteria that can't be tested
- Criteria that are ambiguous about what "done" looks like (e.g. "handles errors appropriately" — what does that mean?)

#### Non-Goals (Scope Fence)
- [ ] At least 1 explicit exclusion
- [ ] Exclusions are specific, not vague
- [ ] Related features explicitly deferred

**Red flags:**
- Empty or missing section
- Vague exclusions like "out of scope stuff"
- No mention of related work being deferred

#### Assumptions & Constraints
- [ ] Key assumptions documented
- [ ] Technical constraints noted
- [ ] Dependencies identified

**Red flags:**
- Empty section (every feature has assumptions)
- Implicit assumptions not made explicit

#### Technical Notes
- [ ] Implementation hints provided (if known)
- [ ] Existing patterns to follow mentioned
- [ ] Files/components likely affected

**Acceptable if empty** - not all specs need technical notes

#### Security Considerations
- [ ] All five prompts filled in (Data flow, Trust boundaries, Auth model, Failure modes, RLS)
- [ ] Answers are specific to this feature, not generic boilerplate
- [ ] "N/A" entries include a reason (e.g., "N/A — UI-only, no data mutation")
- [ ] If new tables: RLS mentioned explicitly
- [ ] If edge functions: auth verification approach stated

**Red flags:**
- Empty section or all "N/A" without reasons
- Generic answers like "standard auth" or "normal validation"
- New database tables with no mention of RLS
- Edge functions with no mention of JWT verification

> See `shared/security-lens.md` for what good answers look like.

#### Open Questions Resolved
- [ ] All questions from interview addressed
- [ ] Decisions documented with reasoning

**Acceptable if empty** - not all interviews surface questions

### Step 3: Assess Readiness

Rate the spec on this scale:

**Ready for Implementation**
- All required sections complete
- Acceptance criteria are testable
- Scope is clearly bounded
- No major gaps

**Needs Minor Revision**
- Most sections complete
- 1-2 small gaps that can be addressed quickly
- Spec is usable but could be improved

**Needs Major Revision**
- Multiple incomplete sections
- Acceptance criteria are vague or missing
- Scope is unclear
- Return to interview phase recommended

### Step 4: Report Findings

Format your response as:

```markdown
## Spec Review: {spec name}

### Readiness: {Ready | Needs Minor Revision | Needs Major Revision}

### Completeness Checklist

**Problem Statement:** {Complete | Incomplete}
- {specific feedback}

**Acceptance Criteria:** {Complete | Incomplete}
- {specific feedback}
- {count} criteria found

**Non-Goals:** {Complete | Incomplete}
- {specific feedback}

**Assumptions:** {Complete | Incomplete}
- {specific feedback}

**Security Considerations:** {Complete | Incomplete}
- {specific feedback}

### Gaps Found
{List specific gaps if any}

### Suggested Questions
{Questions that might have been missed during interview}

### Recommendation
{Clear next step - approve and proceed, or revise specific sections}
```

### Step 5: Do Not Modify

This skill is read-only. Do not:
- Edit the spec document
- Create new files
- Make changes to the codebase

If revisions are needed, tell the user what to change and let them (or the interview skill) make the updates.

## Example

User: `/spec-review Documents/specs/42-dark-mode-spec.md`

Claude:
```markdown
## Spec Review: Dark Mode Toggle

### Readiness: Needs Minor Revision

### Completeness Checklist

**Problem Statement:** Complete
- Clear problem: users want dark mode for eye strain
- Impact: affects all users, especially night-time use
- Beneficiary: all application users

**Acceptance Criteria:** Complete
- 4 testable criteria found
- Edge cases covered (persistence, browser support)

**Non-Goals:** Incomplete
- Only says "not doing system-wide theme"
- Should clarify: custom color themes? Per-page themes?

**Assumptions:** Complete
- Assumes CSS variables already in place
- Assumes local storage is acceptable for persistence

### Gaps Found
1. Non-Goals could be more specific about what theme features are deferred

### Suggested Questions
- Should dark mode sync across devices (if user is logged in)?
- What's the default for new users - light or dark?

### Recommendation
Minor revision needed. Add specifics to Non-Goals section and consider the syncing question. Otherwise ready to proceed.
```

## Best Practices

1. **Be specific** - "Acceptance criteria are vague" is not helpful. Say which criterion and why.
2. **Suggest improvements** - Don't just flag problems, suggest how to fix them.
3. **Be proportionate** - A minor gap shouldn't block implementation if the spec is otherwise solid.
4. **Stay read-only** - This skill analyzes, it doesn't modify.
