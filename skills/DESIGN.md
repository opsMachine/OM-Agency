# Skills System — Design Intent

> **Who this is for:** Anyone extending the skills system — human or agent. Before adding a skill, changing a contract, or restructuring primitives, read this first. It explains WHY, not just WHAT.

---

## Core Principles

These govern every decision in the system. When in doubt, check against these.

1. **Context is finite. Load only what you need, when you need it.** Session start costs ~30 lines. Skills that need stack info read it then, not at load time. Shared primitives (github-ops, spec-io) are referenced on-demand. This is not an optimization — it's the design constraint that everything else follows from.

2. **Composability over monolith.** One skill = one capability. Skills chain via contracts, not via hard-coded call sequences. The router reads contracts to build paths. A new skill slots in by declaring its contract — no other skill needs to change.

3. **Artifacts are the state.** No separate state file. Workflow state lives in spec files and SECURITY_PLAN.md. Skills read and mutate these artifacts directly. The router checks artifact state to know where you are.

4. **Trust boundaries are explicit.** Human gates (A, B, C) are mandatory stops. Skills never auto-proceed past them. This is by design — the value of the workflow is that humans approve specs and review implementations. Removing gates removes the value.

5. **Non-destructive migration.** When the system upgrades (scaffold re-runs, new primitives, structural changes), existing customizations survive. Merge, don't overwrite. The user's project-specific skills, orient entries, and conventions are preserved.

6. **Facts have natural homes.** Every piece of information belongs somewhere specific based on what it IS, not where the user happened to mention it. `/remember` classifies automatically. The classification tables in each target file define the boundaries.

---

## Role Split

Each layer has a job. They don't overlap.

| Layer | File(s) | Contains | Changes how often |
|---|---|---|---|
| Behavioral | `~/.claude/CLAUDE.md` | How to think: coding principles, decision framework, defaults | Rarely |
| Navigation | `skills/AGENTS.md` | Where to find things: orient table, skill map | When skills change |
| Workflow | `skills/*/SKILL.md` | How to do each step: instructions, contracts, examples | When the step changes |
| Shared reference | `skills/shared/*.md` | Reusable patterns: GitHub ops, spec I/O, testing methodology | When the pattern changes |
| Project facts | `.claude/primitives/*.md` | What THIS project is: stack, conventions, dev commands. Optional: glossary (domain terms), architecture (system structure), testing-conventions (project-specific test patterns) | When the project changes |
| Project navigation | `.claude/AGENTS.md` | Where to find project things + session-start instruction | Once (+ merge on scaffold) |
| Session state | `primitives/active-context.md` | What's happening NOW: branch, issues, blockers | Every session |

**Key insight:** primitives are factual snapshots. `active-context.md` is the only exception — it's the scratchpad. Everything else in primitives changes only when the project fundamentally changes.

---

## Why Shared vs Primitives

Skills reference two types of knowledge: **general methodology** (shared/) and **project-specific conventions** (primitives/). This split keeps skills regenerable while respecting project uniqueness.

**Shared docs** (`skills/shared/*.md`) contain patterns that apply to ANY project:
- `github-ops.md` - How to use GitHub CLI (gh pr create, gh issue comment, etc.)
- `spec-io.md` - Spec file structure and I/O patterns
- `e2e-patterns.md` - General E2E testing methodology (Playwright patterns, reconnaissance-then-action)
- `test-planning.md` - Test granularity framework (when to combine vs split tests)

**Primitives** (`.claude/primitives/*.md`) contain facts specific to THIS project:
- `stack.md` - This project's tech stack (Supabase + React)
- `testing-conventions.md` - This project's test patterns (how WE test OUR stack)
- `glossary.md` (optional) - This project's domain terms
- `architecture.md` (optional) - This project's structure

**The rule:** If a skill can use it in ANY project, it's shared. If it's specific to this codebase, it's a primitive.

**Examples:**
- "Use reconnaissance-then-action pattern for E2E tests" → `shared/e2e-patterns.md` (applies everywhere)
- "Test Supabase Edge Functions with real DB, not mocks" → `primitives/testing-conventions.md` (specific to this project)
- "Use gh pr create with --fill flag" → `shared/github-ops.md` (applies everywhere)
- "Deploy with `npm run deploy:staging`" → `primitives/stack.md` (specific to this project)

This separation lets skills be reused across projects (they reference shared/) while adapting to each project's specifics (they reference primitives/).

---

## Why Contracts Exist

Skills without contracts are isolated prompts. Skills with contracts are composable workflow nodes.

A contract declares:
- **What state must be true before this skill runs** (gates). The router checks these.
- **What state this skill changes** (mutates). The router uses this to know what gates will be satisfied next.
- **What skills are valid after this one** (next). The router presents these as options.
- **Whether a human must approve before the next skill runs** (human_gate).

This makes the workflow programmatic. Adding a new step doesn't require editing every other skill — just declare where it fits in the chain via its contract.

**Not everything needs a contract.** Utility skills (remember, scaffold-project, project-context) are standalone. They don't participate in the feature/bug/security workflow. No contract block.

---

## Why Two State Worlds

Feature and bug paths use spec files (`Documents/specs/`). Security paths use `SECURITY_PLAN.md`. They are intentionally isolated.

If they shared state, a security fix could be accidentally marked "done" by a feature workflow state transition. Or a security finding could block a feature deployment. The two paths have different lifecycles, different approval flows, and different stakeholders. Isolation is the right call.

---

## Why Progressive Loading

Every token in context is a token not available for actual work. The session-start instruction in project AGENTS.md reads only `active-context.md` (~30 lines) + git state. That's enough to orient.

When `/implement-direct` needs to know the test runner, it reads `stack.md` at that point. When `/write-failing-test` needs file conventions, it reads `conventions.md`. Skills pull what they need from the orient table in AGENTS.md — they don't load everything upfront.

This is the same pattern as `shared/github-ops.md`: only loaded when a skill actually posts to GitHub, not at session start.

---

## Why Remember Is Scope-Aware

Facts live in two worlds: project and global.

- **Project facts** (this project's deploy command, this project's test runner) belong in `.claude/primitives/`. They're version-controlled, project-specific, and visible to anyone working in the repo.
- **Global facts** (coding rules that apply everywhere, workflow patterns, skill knowledge) belong in `~/.claude/`. They persist across all projects and shape how the agent behaves everywhere.

A single `/remember` command handles both. Scope detection runs first — the classification tables in each target define the boundaries. Ambiguous facts get asked about. This keeps the user interface zero-friction while respecting the structural separation.

---

## Why Scaffold Merges AGENTS.md

Projects evolve. Teams add custom skills, orient entries, runbooks. If scaffold-project blindly overwrote AGENTS.md on re-run, all of that would be lost.

The merge rules are intentional:
- **Structural sections** (session-start blockquote, Conventions) always come from the template — these are the prescribed structure.
- **Orient table rows and skill map entries** are additive — existing project-specific entries survive.
- **Extra sections** (runbooks, team notes) are preserved below the standard structure.

This makes re-running scaffold-project safe. It upgrades the structure without destroying customizations.

---

## Why Primitives Have Three Update Paths

Primitives go stale. The project changes, deps get bumped, scripts get added — and nothing automatically catches it. Three paths keep them current:

- **`/remember`** — in-session, on-demand. You notice something, you store it. Zero friction, immediate.
- **Skill hooks** — automatic end-of-skill checks. Six skills run a lightweight scan at their end (`shared/primitive-updates.md`): implement-direct, implement-to-pass, diagnose, create-spec, qa-handoff, 4-security-fix. If they discover something primitive-worthy (new dep, gotcha, domain term, architectural constraint), they propose the update and ask for confirmation. Skip silently if nothing found.
- **`/scaffold-project` re-run** — periodic deep refresh. Reads the codebase, diffs against existing primitives. Auto-updates what it can derive (versions, scripts, folder structure). Flags what it can't (deployment info, gotchas, glossary, architecture). Produces a staleness report.

**What's auto-updatable vs not:**

| Auto-update (re-derived from codebase) | Flag only (manually curated) | Never touch on review |
|---|---|---|
| Versions, package manager, framework | Deployment commands, env vars | `active-context.md` |
| Scripts, dev port | Common Gotchas | |
| Folder structure, component patterns | MCP Servers, Key Dependencies | |
| | Glossary terms, Architecture docs | |

Skills don't write to primitives directly — they propose updates via confirmation. The user is still the gate. This keeps primitives trustworthy without creating coupling.

---

## Why Glossary and Architecture Are Optional

Not every project needs them. A simple CRUD app doesn't need an architecture doc — the structure is self-evident. A toy project doesn't need a glossary — the terms are standard.

- **glossary.md** exists for domain-heavy projects where terms are non-obvious or conflict with common usage (legal, medical, finance, etc.). An empty glossary is worse than no glossary — it wastes context on nothing.
- **architecture.md** exists for projects where the structure isn't self-evident from the file tree — multiple services, complex data flows, non-obvious boundaries. It's about the WHY, not the WHAT (stack.md covers WHAT).

Scaffold-project detects signals and only creates them when justified. Both are on-demand like all other primitives — not loaded at session start.

---

## How to Extend

### Adding a new workflow skill

1. Create `skills/<name>/SKILL.md`
2. Add a `contract:` block. Declare gates (what must be true before it runs), mutates (what it changes), next (what's valid after), human_gate (does a human need to approve before the next skill?)
3. Add it to `skills/AGENTS.md` — orient table row + skill map entry
4. Add it to `workflow-router/SKILL.md` — skill index table + tag lookup + relevant decision tree

### Adding a new utility skill

1. Create `skills/<name>/SKILL.md`
2. No contract block needed
3. Add it to `skills/AGENTS.md` — orient table row + skill map entry
4. That's it. Utility skills don't participate in the workflow chain.

### Adding a new primitive

1. Add the file to the scaffold-project template (Phase 2)
2. Add it to the project AGENTS.md template (orient table + primitive map)
3. Add a classification row to remember's decision table (so facts route there)
4. Update this file if the primitive represents a new design decision

### Changing a contract

If you change what a skill gates on or mutates, check:
- Does any other skill's `next` point to this one? Its gate expectations may have changed.
- Does the router's decision tree still work? Update it.
- Does the skill index in workflow-router still match?

Contracts are the wiring. Changes ripple.

---

## What Not To Do

- **Don't add features not in the spec.** This applies to the skills system itself. Don't add a skill nobody asked for.
- **Don't create abstractions for one-time operations.** If only one skill needs a pattern, put it in that skill. Don't extract it to shared/.
- **Don't auto-proceed past human gates.** Ever. The gates are the value.
- **Don't load primitives at session start "just in case."** Read them when you need them. Context is finite.
- **Don't make skills depend on each other's internal structure.** Skills interact via contracts and shared artifacts. If skill A needs to know how skill B formats its output, that's a coupling smell — extract it to a shared primitive.
