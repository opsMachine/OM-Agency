# Skills System

> **MANDATORY FIRST ACTION:** Before responding to ANY work request, read `~/.claude/skills/workflow-router/SKILL.md` and follow its Quick Start checklist. Announce `🎯 Workflow Manager active. Checking project state...`, orient, then propose the next skill. Do NOT skip this step.

Modular skill ecosystem for Claude Code and Cursor. Skills are composable workflow nodes with typed contracts.

## What This Repo Is

This is the skill system itself — not a product codebase. Changes here affect how agents work across all projects.

## Key References

| Need | File |
|------|------|
| Workflow navigation & state model | `skills/workflow-router/SKILL.md` |
| System design history | `~/.claude/docs/OPERATIONAL_SYSTEM.md` |
| Skill contracts & shared primitives | `skills/shared/` |

## Active Skills (v2)

| Skill | Purpose | Human Gate? |
|-------|---------|-------------|
| `interview` (create-spec) | Requirements gathering → spec | Yes (Gate A) |
| `implement` | One-shot: tests + code + self-verify | No |
| `verify` | Fresh-context review of implementation | Yes (Gate B) |
| `diagnose` | Bug investigation → bug spec | No |
| `qa-handoff` | Post QA checklist to GitHub issue | No (terminal) |
| `review-audit` | Validate a code review against code | No (standalone) |
| Security pipeline (4 skills) | Security audit → critique → spec → fix | Yes (Gate C) |

**Standalone (user invokes directly):**
- `scaffold-project` — bootstrap project context
- `supabase-security` — Supabase security reference
- `remember` — store facts for future sessions

## Workflow Model

```
interview → [Gate A] → implement → verify → [Gate B] → qa-handoff → DONE
```

State lives in the spec file: `Draft` → `Approved` → `Implemented`

## When Editing Skills

- Follow existing patterns in other SKILL.md files
- Every skill needs a `contract:` block in frontmatter
- Reference `shared/spec-io.md` and `shared/github-ops.md` instead of duplicating
- Use brief + guardrails style (WHAT/WHY, not step-by-step HOW)
- Test by invoking the skill in a real project
