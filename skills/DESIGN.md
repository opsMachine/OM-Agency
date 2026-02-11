# Skills System — Design Intent (v3.1)

> **Who this is for:** Anyone extending the skills system — human or agent. Before adding a skill, changing a contract, or restructuring primitives, read this first. It explains WHY, not just WHAT.

---

## Core Principles

These govern every decision in the system. When in doubt, check against these.

1. **Context is finite. Load only what you need, when you need it.** Session start costs ~30 lines. Shared primitives and project facts are referenced on-demand. This is the design constraint that everything else follows from.

2. **Composability over monolith.** One skill = one capability. Skills chain via contracts. A new skill slots in by declaring its contract — no other skill needs to change.

3. **Artifacts are the state.** Workflow state lives in spec files, `active-context.md`, and `SECURITY_PLAN.md`. No separate state file.

4. **Trust boundaries are explicit.** Human gates (A, B, C) are mandatory stops. Skills never auto-proceed past them.

5. **Todo-Driven Execution (v3.1)**: Prose instructions are secondary. Native IDE todo lists are the primary execution and self-review mechanism. This ensures reliability and visible progress.

6. **Principles vs SOPs**: High-level guidance (judgment) lives in the `SKILL.md` file. Specific procedures (operations) are generated into native todo lists.

7. **Visible Handshake**: Every session MUST start with a mandatory orientation 🎯. This prevents protocol drift and ensures the agent is in character.

---

## Role Split

Each layer has a job. They don't overlap.

| Layer | File(s) | Contains | Changes how often |
|---|---|---|---|
| Behavioral | `CLAUDE.md` | Orientation mandate, instruction hierarchy, coding principles | Rarely |
| Navigation | `skills/AGENTS.md` | Where to find things: skill map, quick start | When skills change |
| Workflow | `skills/*/SKILL.md` | Principles, contracts, and **Todo Templates** | When the phase changes |
| Shared reference | `skills/shared/*.md` | Reusable methodology: GitHub ops, spec I/O, testing | When the pattern changes |
| Project facts | `.claude/primitives/*.md` | What THIS project is: stack, conventions, dev commands | When the project changes |
| Project navigation | `.claude/AGENTS.md` | Where to find project things | Once (+ merge on scaffold) |
| Session state | `primitives/active-context.md` | What's happening NOW: branch, issues, blockers | Every session |

---

## Why Todo-Driven Execution

Prose instructions are easily glossed over. Native todo lists:
- **Prevent step-skipping**: Each item is a discrete checkbox.
- **Ensure honest review**: Verification items cannot be ignored without leaving them unchecked.
- **Support resumption**: Checking the list is the fastest way to re-orient after interruption.
- **Provide visibility**: Both agent and user see exactly what's done and what's next.

---

## Why Principles vs SOPs

Standard Operating Procedures (SOPs) are repetitive and mechanical — they belong in the todo list. Principles require reasoning and judgment — they belong in the `SKILL.md` guidance. An agent uses the Principles to execute the SOPs.

---

## Why Risk-Adaptive Modes

Not every task needs a full TDD pipeline.
- **Lightweight Mode**: Fast flow for low-risk UI/copy/docs. Skips the isolated TEST phase.
- **Structured Mode**: Full rigor for auth, payments, DB, and complex logic. Mandatory TEST phase.

The agent proposes the mode during `UNDERSTAND`, and the human approves at **Gate A**.

---

## How to Extend

### Adding a new workflow skill

1. Create `skills/<name>/SKILL.md`.
2. Add a `contract:` block.
3. Define **Purpose & Principles**.
4. Define a **Todo Template** that instantiates the skill's operations.
5. Add it to `skills/AGENTS.md`.

### Adding a new utility skill

1. Create `skills/<name>/SKILL.md`.
2. No contract or todo template needed if it doesn't participate in the workflow.

---

## What Not To Do

- **Don't add features not in the spec.**
- **Don't auto-proceed past human gates.**
- **Don't skip the Orientation Todo List at session start.**
- **Don't claim a todo is complete until you have verified the outcome.**
