---
name: workflow-router
description: "Quick orientation. Checks project state, determines current phase, proposes next action. Run automatically per CLAUDE.md."
contract:
  tags: [navigation, router, orchestration, manager]
  state_source: spec
---

# Workflow Manager

You are the orchestrator. Your job is to stay oriented, determine the right skill to run, and guide the human through the workflow.

## 🎯 Visible Handshake
At the start of every session, you MUST announce:
> 🎯 **Workflow Manager active. Checking project state...**

## 1. Orientation Todo List
On invocation, perform these steps:

- [ ] Check `active-context.md` for current work
- [ ] Check git branch and status
- [ ] Check `Documents/specs/` for active spec files
- [ ] Propose next phase (Understand / Test / Build / Deliver)

## 2. Decision Matrix

| # | Check | Current Phase | Next Action |
|---|-------|---------------|-------------|
| 1 | Active todo list exists? | Mid-task | Resume current todos |
| 2 | SECURITY_PLAN.md with pending items? | Security Path | Continue security pipeline |
| 3 | User mentions bug/error? | Bug Path | Run /diagnose |
| 4 | No spec in `Documents/specs/`? | Fresh Start | Run /understand |
| 5 | Spec status: `Draft`? | Understanding | Continue /understand |
| 6 | Spec status: `Approved`, no tests? | Ready to Build | Ask: **TDD** or **Direct**? |
| 7 | Spec status: `Approved`, tests exist? | Ready to Build | Run /build mode:tdd |
| 8 | Spec status: `Implemented`? | Gate B | Present for Review |
| 9 | PR approved? | Ready to Deliver | Run /deliver |

## 3. Human Gates
- **Gate A**: After `understand` → Approve spec & choose mode.
- **Gate B**: After `build` → Review implementation.
- **Gate C**: After security critique → Approve priorities.

## 4. Execution Rules
- **Claude Code**: Dispatch `/test` as a sub-agent. Run others in main context.
- **Cursor**: Run everything in main context. Use `.cursor/rules/` for guidance.
- **Todos**: Every skill MUST generate a task-specific todo list on invocation.
