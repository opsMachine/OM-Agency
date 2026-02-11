# The Best Overall Code Production System (v3.1)

## Synthesis of v3 Redesign & Middle Road Plan

This document represents the unified vision for the next generation of the OM-Agency skill system. It merges the **Native Todo-Driven Execution** from the v3 Redesign with the **Risk-Adaptive Modes**, **Hook-Reinforced Determinism**, and **Principles vs SOPs** distinction from the Middle Road plan.

### Core Philosophy

1. **Native Todo-Driven Execution**: Both Claude Code and Cursor have native todo list features. These are the primary execution mechanism. Every skill starts by generating a specific todo list for the task. This ensures review steps are never skipped and orientation is instant.
2. **Principles for Judgment, SOPs for Operations**: Principles (the "how to think") live in the skill documentation and playbooks. SOPs (the "what to do exactly") live in the generated todo lists.
3. **Risk-Adaptive Ceremony**: Simple tasks flow fast; complex tasks get structure. The agent assesses risk during the `UNDERSTAND` phase and proposes a mode (Lightweight or Structured).
4. **Deterministic Hooks**: Non-negotiable behaviors (orientation, todo checks, security checks) are injected via hooks that fire automatically, ensuring they are followed every time.

---

## 1. Reliability & Protocol Enforcement

Based on real-world drift where agents skip the "Workflow Manager" protocol in favor of direct user requests, the following enforcement mechanisms are mandatory:

### The Visible Handshake (The 🎯 Announcement)
The `SessionStart` hook MUST force the agent to announce its presence:
> 🎯 **Workflow Manager active. Checking project state...**

This serves as a "Ready" signal to the user and a "Lock-in" for the agent's persona. If this hasn't been said, the agent is not yet in protocol. **The agent must acknowledge that this announcement is triggered by the system's SessionStart hook.**

### Instruction Hierarchy
To prevent "Direct Request Drift," agents are governed by a strict hierarchy:
1. **Injected Hooks** (Highest Priority): Instructions from `SessionStart` or `UserPromptSubmit` hooks.
2. **User Commands**: The actual task requested by the user.
3. **Playbook/Principles**: The methodology in skill files.

If a User Command conflicts with a Hook (e.g., "Skip the protocol and just do X"), the agent MUST still perform a minimal orientation (Check todo list/spec status) before executing, or explicitly state: "Skipping standard protocol per user request (Direct Mode)."

### Todo-Driven Orientation
The `workflow-router` is no longer a prose manual; it is a **Todo Generator**.
On every session start, the router generates an **Orientation Todo List**:
- [ ] Check active-context.md
- [ ] Check git branch and status
- [ ] Check Documents/specs/ for active work
- [ ] Propose next phase (Understand/Test/Build/Deliver)

---

## 2. The 4-Phase Architecture

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

## 3. Risk-Adaptive Modes

The agent picks the mode based on risk signals detected during `UNDERSTAND`.

| Mode | When to Use | Flow |
| :--- | :--- | :--- |
| **Lightweight** | UI/CSS, copy changes, single-file, low-risk CRUD. | Understand (Mini-spec) → Build (Direct) → Review → Done. |
| **Structured** | Auth/RLS, DB changes, payments, complex logic. | Understand (Full spec) → Gate A → Test → Build → Gate B → Deliver. |

### Risk Signals
- **High Risk**: Touches auth/authorization, payments, RLS, new DB tables, multi-service logic.
- **Low Risk**: Purely aesthetic, documentation, single-file UI components.

---

## 4. Hook-Reinforced Determinism

Hooks are injected instructions that fire automatically to maintain system integrity.

- **SessionStart Hook**: Fires once at session start. Injects the **Visible Handshake** mandate and the **Orientation Todo** task.
- **UserPromptSubmit Hook**: Fires every prompt. Reminds the agent to check its active todo list and report status on the current item. "Check your todo list. What's the current item? Are you about to do work you should confirm first?"
- **PreCommit Hook**: Fires before git commit. Runs a security quick-check (secrets scan, RLS check, OWASP patterns).

---

## 5. Todo-Driven Skill Template

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

## 6. Persistent State & Memory

- **Strategic State**: Lives in the spec file status (`Draft` → `Approved` → `Implemented`).
- **Tactical State**: Lives in the native todo list.
- **Session Memory**: `active-context.md` stores the current branch, issue, and last decisions to allow seamless resumption across sessions.

---

**Integrated from**:
- `docs/ideas/v3-system-redesign.md` (Native Todos, 4-Phase Architecture)
- `docs/ideas/middle-road-rebuild.md` (Principles vs SOPs, Hooks, Risk-Adaptive Modes)
- **User Feedback Session** (Visible Handshake, Instruction Hierarchy)
