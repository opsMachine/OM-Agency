# OM-Agency Skills System (v3.1)

Modular skill ecosystem for Claude Code and Cursor. Skills are composable workflow nodes with typed contracts that orchestrate AI-assisted development workflows.

## The Craftsperson Model

The system utilizes a 4-phase todo-driven workflow designed to minimize context loss and ensure high-quality execution:

1. **UNDERSTAND** — Requirements gathering, spec assembly, and self-review. [Gate A Approval]
2. **TEST** — Test planning and writing failing tests.
3. **BUILD** — Implementation (TDD or Direct mode) and verification. [Gate B Approval]
4. **DELIVER** — QA handoff and GitHub state synchronization.

## Key Innovations

- **Todo-Driven Execution**: Skills generate native IDE todo lists to ensure no step is skipped and progress is visible.
- **Principles vs SOPs**: High-level guidance lives in documentation; specific procedures are baked into the generated todo lists.
- **Risk-Adaptive Modes**: Choose **Lightweight** (fast flow) or **Structured** (full TDD) based on task risk.
- **Visible Handshake**: Every session starts with a mandatory orientation 🎯 to prevent protocol drift.

## Quick Start

1. Clone this repo
2. Symlink into your Claude Code config:
   ```bash
   ln -s /path/to/OM-Agency/skills ~/.claude/skills
   ln -s /path/to/OM-Agency/agents ~/.claude/agents
   ln -s /path/to/OM-Agency/hooks ~/.claude/hooks
   ```
3. For Cursor, symlink the rules:
   ```bash
   ln -s /path/to/OM-Agency/.cursor/rules .cursor/rules
   ```
4. **Register Hooks & Permissions**: Copy `settings.example.json` to your global `~/.claude/settings.json` (or merge if you have existing settings).
   *Note: Symlinking the hook folder is not enough; the scripts must be registered in the `hooks` section of your settings to fire.*
5. See `skills/SKILL.md` for the skill writing guide.

## Structure

```
skills/           Unified workflow skills (Understand, Test, Build, Deliver)
agents/           Sub-agent definitions for skill dispatch
hooks/            Automation scripts (SessionStart, UserPromptSubmit)
docs/archive/     v2.0 legacy skills and design history
```

## License

MIT
