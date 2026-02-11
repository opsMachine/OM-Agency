# OM-Agency Skills System

Modular skill ecosystem for Claude Code and Cursor. Skills are composable workflow nodes with typed contracts that orchestrate AI-assisted development workflows.

## 🎯 MANDATORY FIRST ACTION
Before responding to ANY work request, you MUST:
1. Announce: `🎯 Workflow Manager active. Checking project state...`
2. Read `skills/workflow-router/SKILL.md`
3. Generate the **Orientation Todo List** defined in the router.
4. Report findings and propose the next skill.
5. Wait for human confirmation before proceeding.

## Instruction Hierarchy (Enforcement)
1. **Injected Hooks** (Highest Priority): Instructions from session start or prompt hooks.
2. **User Commands**: The specific task requested.
3. **Playbook/Principles**: Methodology in skill files.

*Note: If a user command conflicts with the orientation mandate, orient first, then execute.*

## Key References

| Need | File |
|------|------|
| Workflow navigation & state model | `skills/workflow-router/SKILL.md` |
| System design history | `docs/design-history.md` |
| Skill contracts & shared primitives | `skills/shared/` |

## When Editing Skills

- Every skill needs a `contract:` block in frontmatter.
- Every workflow skill MUST generate a **task-specific todo list** on invocation.
- Reference `shared/spec-io.md` and `shared/github-ops.md` instead of duplicating.
- Follow the **Principles vs SOPs** distinction: Docs carry principles; Todos carry SOPs.
