# OM-Agency Skills System

Modular skill ecosystem for Claude Code and Cursor. Skills are composable workflow nodes with typed contracts that orchestrate AI-assisted development workflows.

## What This Is

A reusable workflow system for AI agents that covers:

- **Feature development** — requirements gathering, spec creation, TDD or direct implementation
- **Bug investigation** — diagnosis, root cause analysis, fix verification
- **Security auditing** — 4-phase pipeline (scan, critique, test, fix)
- **Project scaffolding** — context primitives, testing conventions, active state

## Quick Start

1. Clone this repo
2. Symlink into your Claude Code config:
   ```bash
   ln -s /path/to/OM-Agency/skills ~/.claude/skills
   ln -s /path/to/OM-Agency/agents ~/.claude/agents
   ```
3. Copy `settings.example.json` to your project's `.claude/settings.json` and adjust
4. See `skills/SKILL.md` for the full skill writing guide

## Structure

```
skills/           19 skill definitions + shared patterns
agents/           Sub-agent definitions for skill dispatch
commands/         Custom command definitions
```

## Key Files

| File | Purpose |
|------|---------|
| `skills/AGENTS.md` | Entry point — where to start, what skill to use |
| `skills/DESIGN.md` | Architecture and design philosophy |
| `skills/SKILL.md` | Guide for writing new skills |
| `skills/workflow-router/SKILL.md` | The workflow orchestrator |
| `skills/shared/` | Reusable patterns (spec I/O, GitHub ops, security lens, etc.) |
| `OPERATIONAL_SYSTEM.md` | System philosophy and history |

## Skills

| Skill | Purpose |
|-------|---------|
| `workflow-router` | Orchestrates the entire workflow — determines next step |
| `create-spec` | Structured requirements gathering |
| `spec-review` | Reviews specs for completeness |
| `implement-direct` | Implement from spec without TDD |
| `implement-to-pass` | Green phase — make failing tests pass |
| `plan-tests` | Create test plan from spec |
| `write-failing-test` | Red phase — write tests that fail |
| `diagnose` | Bug investigation and root cause analysis |
| `qa-handoff` | Post testing checklist to GitHub issue |
| `scaffold-project` | Bootstrap project context primitives |
| `remember` | Store facts and decisions for future sessions |
| `full-security-audit` | Orchestrate 4-phase security pipeline |
| `1-security-audit` | Phase 1: Scan for vulnerabilities |
| `2-security-critique` | Phase 2: Red team review |
| `3-security-spec` | Phase 3: Write failing security test |
| `4-security-fix` | Phase 4: Implement the fix |
| `supabase-security` | Supabase-specific security patterns |
| `webapp-testing` | Browser automation testing toolkit |

## License

MIT
