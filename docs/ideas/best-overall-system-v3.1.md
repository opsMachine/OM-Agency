# The Best Overall Code Production System (v3.1)

## Synthesis of v3 Redesign & Middle Road Plan

This document represents the unified vision for the next generation of the OM-Agency skill system. It merges the **Native Todo-Driven Execution** from the v3 Redesign with the **Risk-Adaptive Modes**, **Hook-Reinforced Determinism**, and **Principles vs SOPs** distinction from the Middle Road plan.

### Core Philosophy

1. **Native Todo-Driven Execution**: Both Claude Code and Cursor have native todo list features. These are the primary execution mechanism. Every skill starts by generating a specific todo list for the task. This ensures review steps are never skipped and orientation is instant.
2. **Principles for Judgment, SOPs for Operations**: Principles (the "how to think") live in the skill documentation and playbooks. SOPs (the "what to do exactly") live in the generated todo lists.
3. **Risk-Adaptive Ceremony**: Simple tasks flow fast; complex tasks get structure. The agent assesses risk during the `UNDERSTAND` phase and proposes a mode (Lightweight or Structured).
4. **Deterministic Hooks**: Non-negotiable behaviors (orientation, todo checks, security checks) are injected via hooks that fire automatically, ensuring they are followed every time.

---

## 1. The 4-Phase Architecture

The system is consolidated into four primary phases, reducing context loss and sub-agent overhead.

### Phase 1: UNDERSTAND (Interactive, Main Context)
- **Replaces**: `create-spec` + `spec-review` + `diagnose` (initial)
- **Goal**: Define the problem, requirements, and assess risk.
- **Outcome**: A spec (Full or Mini) + Risk Assessment + Operational Mode.
- **Human Gate A**: User approves spec and mode.

### Phase 2: TEST (Sub-agent in Claude Code / Isolated in Cursor)
- **Replaces**: `plan-tests` + `write-failing-test`
- **Goal**: Create failing tests that define the done-state.
- **Outcome**: Failing tests on disk.
- **Note**: Skippable in **Lightweight Mode**.

### Phase 3: BUILD (Main Context)
- **Replaces**: `implement-to-pass` + `implement-direct`
- **Goal**: Implementation and verification.
- **Outcome**: Working code + Satisfaction Assessment (✅/⚠️/❌).
- **Human Gate B**: User reviews implementation.

### Phase 4: DELIVER (Main Context)
- **Replaces**: `qa-handoff` + GitHub cleanup
- **Goal**: Hand off to QA and close the loop.
- **Outcome**: QA checklist on issue + PR linked/merged.

---

## 2. Risk-Adaptive Modes

The agent picks the mode based on risk signals detected during `UNDERSTAND`.

| Mode | When to Use | Flow |
| :--- | :--- | :--- |
| **Lightweight** | UI/CSS, copy changes, single-file, low-risk CRUD. | Understand (Mini-spec) → Build (Direct) → Review → Done. |
| **Structured** | Auth/RLS, DB changes, payments, complex logic. | Understand (Full spec) → Gate A → Test → Build → Gate B → Deliver. |

### Risk Signals
- **High Risk**: Touches auth/authorization, payments, RLS, new DB tables, multi-service logic.
- **Low Risk**: Purely aesthetic, documentation, single-file UI components.

---

## 3. Hook-Reinforced Determinism

Hooks are injected instructions that fire automatically to maintain system integrity.

- **SessionStart Hook**: Fires once at session start. Loads `active-context.md`, checks git state, and reads the orientation playbook.
- **UserPromptSubmit Hook**: Fires every prompt. Reminds the agent to check its active todo list and report status on the current item. "Check your todo list. What's the current item? Are you about to do work you should confirm first?"
- **PreCommit Hook**: Fires before git commit. Runs a security quick-check (secrets scan, RLS check, OWASP patterns).

---

## 4. Todo-Driven Skill Template

Every workflow skill follows this structure:

```markdown
## Purpose & Principles
~20 lines: Why this skill exists and how to exercise judgment. (The Principles)

## Todo Template
The specific checkboxes to create on invocation. (The SOPs)
- [ ] Task 1
- [ ] Task 2
- [ ] VERIFY: Criterion A matches...
- [ ] REVIEW: Security check...

## References
Pointers to shared docs (github-ops.md, etc.).
```

---

## 5. Persistent State & Memory

- **Strategic State**: Lives in the spec file status (`Draft` → `Approved` → `Implemented`).
- **Tactical State**: Lives in the native todo list.
- **Session Memory**: `active-context.md` stores the current branch, issue, and last decisions to allow seamless resumption across sessions.

---

## Migration Strategy

1. **Unified Skill Creation**: Create the 4 core skills (`understand`, `test`, `build`, `deliver`) using the todo-driven template.
2. **Hook Implementation**: Add the deterministic hooks to `CLAUDE.md` or the tool settings.
3. **Documentation Archive**: Move old specialized skills to `docs/archive/skills-v2/`.
4. **Tool Integration**: Deploy Cursor rules (`.cursor/rules/`) to ensure parity between Claude Code and Cursor.

---

**Integrated from**:
- `docs/ideas/v3-system-redesign.md` (Native Todos, 4-Phase Architecture)
- `docs/ideas/middle-road-rebuild.md` (Principles vs SOPs, Hooks, Risk-Adaptive Modes)
