---
name: skill-writer
description: Guide users through creating Agent Skills for Claude Code. Use when the user wants to create, write, author, or design a new Skill, or needs help with SKILL.md files, frontmatter, or skill structure.
---

# Skill Writer

This Skill helps you create well-structured Agent Skills for Claude Code that follow best practices and validation requirements.

## 🎯 v3.1 Architecture: Todo-Driven Execution

All workflow skills in the OM-Agency system follow the **v3.1 Todo-Driven Architecture**. This ensures reliability, visible progress, and easy resumption after interruption.

### Key Principles
1. **Principles for Judgment, SOPs for Operations**: The `SKILL.md` file contains the high-level principles (the "why" and "how to think"). The `Todo Template` contains the specific procedures (the "what to do exactly").
2. **Native Todo Lists**: Agents MUST use the native todo list features of their IDE (Claude Code's Task tool or Cursor's todo checklists).
3. **Execution Contract**: The generated todo list is a contract. Every verification and review step must be a discrete, checkable item.

---

## Skill File Structure

Every workflow skill MUST have these three sections:

### 1. Purpose & Principles
~20 lines of guidance on when to use the skill and the core principles governing its execution.

### 2. Todo Template
The exact markdown checklist to be instantiated on invocation. This must be adapted to the specific task (e.g., replacing placeholders with criterion text).

### 3. References
Pointers to shared methodology docs (e.g., `shared/github-ops.md`, `shared/spec-io.md`).

---

## Instructions

### Step 1: Write SKILL.md Frontmatter

Create YAML frontmatter with required fields:

```yaml
---
name: skill-name
description: Brief description of what this does and when to use it
contract:
  tags: [tag1, tag2]
  state_source: spec | security_plan
  inputs:
    params:
      - name: param_name
        required: true
    gates:
      - field: "status"
        value: "Approved"
  outputs:
    mutates:
      - field: "status"
        sets_to: "Implemented"
  next: [next-skill]
  human_gate: true
---
```

### Step 2: Define Purpose & Principles
Explain the mental model. Why does this skill exist? What are the non-negotiable standards?

### Step 3: Create the Todo Template
This is the most critical part. Break the skill's operations into atomic, checkable steps.

**Template Pattern:**
- [ ] **Phase 1: Preparation**
  - [ ] Action 1
  - [ ] Action 2
- [ ] **Phase 2: Execution**
  - [ ] Implementation of {criterion}
- [ ] **Phase 3: Verification**
  - [ ] VERIFY: {criterion} satisfies {condition}
- [ ] **Phase 4: Handoff**
  - [ ] Update artifact state
  - [ ] Report status

### Step 4: Add References
Link to existing shared primitives to avoid duplication.
- `shared/github-ops.md`: GitHub CLI patterns
- `shared/spec-io.md`: Spec file structure and I/O
- `shared/security-lens.md`: Security thinking

---

## Writing Contracts

If your skill participates in the workflow system (feature path, bug path, security path), add a `contract:` block to frontmatter. The contract is what makes chaining programmatic.

### Contract fields

```yaml
contract:
  tags: [tag1, tag2]           # Capability tags: intake, tdd, implementation, testing, security, github, closure
  state_source: spec           # Artifact source: spec | security_plan
  inputs:
    params:                    # Explicit arguments
      - name: spec_path
        required: true
    gates:                     # State conditions required BEFORE running
      - field: "status"        # Field path inside the state artifact
        value: "Approved"      # Required value
  outputs:
    mutates:                   # State fields this skill WRITES
      - field: "Test Plan.status"
        sets_to: "Tests Written"
    side_effects: []           # e.g. "Comments GitHub issue"
  next: [skill-name]           # Valid next skills
  human_gate: false            # If true: workflow pauses for human approval AFTER completion
```

## Best Practices

1. **Keep it Focused**: One skill = one capability.
2. **Assessable Criteria**: Todos should be objective outcomes, not vague instructions.
3. **Use Shared Primitives**: Don't re-implement GitHub ops or spec reading.
4. **Visibility**: Ensure the agent announces it has started the skill and generated its todo list.
