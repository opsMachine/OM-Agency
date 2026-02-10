---
name: remember
description: "Store a fact, decision, or instruction into the right context file. Project-scoped facts go to .claude/primitives/. Global facts (coding rules, workflow patterns, skill knowledge) go to ~/.claude/ files. Use when the user says 'remember', 'note that', 'add to context', 'don't forget', or wants something saved for future sessions. Auto-detects scope."
allowed-tools: Read, Edit, Glob
---

# Remember

Zero-friction memory. Say it, the agent stores it in the right place — project or global — automatically.

---

## Step 1: Detect Scope

Every fact is either **project-scoped** or **global**. This determines which files get read and written.

| Signals | Scope |
|---|---|
| This project's stack, deploy commands, scripts, ports, env vars, current work, conventions | **Project** |
| Coding rules ("always do X", "never do Y"), workflow patterns, how to use skills, decision rules, default tech choices | **Global** |
| A skill that exists or how to find it | **Global** (→ `skills/AGENTS.md`) |
| **Ambiguous** | Ask the user: "Should this be project-specific or global (applies to all projects)?" |

---

## Step 2: Read (scope-dependent)

### Project scope
Read these files. Requires `/scaffold-project` to have been run first — if `.claude/primitives/` doesn't exist, warn and stop.

- `.claude/primitives/stack.md`
- `.claude/primitives/conventions.md`
- `.claude/primitives/local-dev.md`
- `.claude/primitives/active-context.md`

### Global scope
Read these files:

- `~/.claude/CLAUDE.md`
- `~/.claude/skills/AGENTS.md`

---

## Step 3: Classify

### Project classification

| The fact is about... | Store in | Section |
|---|---|---|
| Deploy commands, CI/CD, server info, GitHub Actions | `local-dev.md` | Deployment |
| Dev commands, scripts, ports, env vars, gotchas | `local-dev.md` | Relevant section |
| Framework, library, version change, MCP server, tool | `stack.md` | Relevant section |
| File naming, component patterns, import style, conventions | `conventions.md` | Relevant section |
| Current work, sprint focus, active issue, blocker, decision | `active-context.md` | Relevant section |
| Domain term, acronym, jargon definition | `glossary.md` | (add row to table) — only if glossary.md exists |
| System structure, data flow, module boundaries, architectural constraints | `architecture.md` | Relevant section — only if architecture.md exists |
| **Unclear** | Ask the user | — |

**Project disambiguation rules:**
- One-time fact about what's happening NOW → `active-context.md`
- Permanent fact about how the project WORKS → `stack.md`, `conventions.md`, or `local-dev.md`
- Mentions a specific tool, library, or server → `stack.md`
- "Don't do X" or "always do Y" rule → `conventions.md` or `local-dev.md` Common Gotchas

### Global classification

| The fact is about... | Store in | Section |
|---|---|---|
| How to approach code, coding rules, what to avoid | `CLAUDE.md` | Coding Principles |
| Workflow steps, when to use which skill | `CLAUDE.md` | Workflow |
| How sessions should start or end | `CLAUDE.md` | Session Protocol |
| When to ask vs when to just proceed | `CLAUDE.md` | Decision Framework |
| Default tech stack, commit style, error handling | `CLAUDE.md` | Defaults |
| User or team context (who works here, communication style) | `CLAUDE.md` | Who You're Working With |
| A skill that exists, or how to navigate skills | `skills/AGENTS.md` | Orient Here or Skill Map |
| **Unclear** | Ask the user | — |

---

## Step 4: Write

Add the fact to the correct file and section. Rules:

- **Append, don't replace.** Add to the appropriate section. Don't rewrite the whole file.
- **Be concise.** One line if possible. A short paragraph at most.
- **Use the existing format.** If the section has a table, add a row. If it has a list, add a bullet.
- **Update the date.** If the file has a `**Last Updated:**` field, update it to today's date.

---

## Step 5: Confirm

Tell the user exactly what was stored and where:

> Stored in `<file path>` under **<Section>**:
> `<the fact, as written>`

---

## Examples

### Project-scoped

**Input:** "remember we deploy with npm run deploy:prod to staging"
**Scope:** Project (deploy command for this project)
**Classification:** Deploy command → `local-dev.md` → Deployment
**Action:** Add `- **Staging:** \`npm run deploy:prod\`` to the Deployment section
**Confirmation:** Stored in `.claude/primitives/local-dev.md` under **Deployment**

**Input:** "remember we have a Sentry MCP server for error monitoring"
**Scope:** Project (tool available in this project)
**Classification:** MCP server → `stack.md` → Tools / MCP Servers
**Action:** Add `- Sentry MCP — error monitoring and issue tracking` to Tools / MCP Servers
**Confirmation:** Stored in `.claude/primitives/stack.md` under **Tools / MCP Servers**

**Input:** "remember don't use npx supabase, use supabase directly"
**Scope:** Project (this project's gotcha)
**Classification:** Gotcha → `local-dev.md` → Common Gotchas
**Action:** Add `- Never use \`npx supabase\` — use \`supabase\` directly` to Common Gotchas
**Confirmation:** Stored in `.claude/primitives/local-dev.md` under **Common Gotchas**

### Global-scoped

**Input:** "remember: always run the linter before committing"
**Scope:** Global (coding rule, applies everywhere)
**Classification:** Coding rule → `CLAUDE.md` → Coding Principles
**Action:** Add `- **Lint before commit** — always run the linter before committing` to the Don't/Core Rules list
**Confirmation:** Stored in `~/.claude/CLAUDE.md` under **Coding Principles**

**Input:** "remember: when in doubt about error handling, log the raw error in dev"
**Scope:** Global (decision rule)
**Classification:** Decision pattern → `CLAUDE.md` → Decision Framework or Defaults
**Action:** Add a row or bullet in the appropriate section
**Confirmation:** Stored in `~/.claude/CLAUDE.md` under **Defaults**

**Input:** "remember: there's a scaffold-project skill for setting up new projects"
**Scope:** Global (skill knowledge)
**Classification:** Skill navigation → `skills/AGENTS.md` → Orient Here
**Action:** (Only if not already there) Add orient row
**Confirmation:** Stored in `~/.claude/skills/AGENTS.md` under **Orient Here**

---

## What This Skill Does NOT Do

- Does not delete or overwrite existing content
- Does not store secrets or sensitive values (warn if user tries)
- Does not run `/scaffold-project` for you (prerequisite for project-scoped facts)
- Does not modify spec files, security plans, or any workflow artifact
