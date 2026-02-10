# Skills System

A modular skill ecosystem for Claude Code. Skills are composable workflow nodes with typed contracts. This file is the entry point — read it first, then follow the pointers.

---

## Orient Here

| If you need to... | Read this |
|-------------------|-----------|
| Figure out what to do next | `workflow-router/SKILL.md` — state model + decision trees |
| Post to GitHub | `shared/github-ops.md` — all `gh` CLI patterns |
| Read or write a spec file | `shared/spec-io.md` — spec structure and I/O |
| Plan or write E2E tests | `shared/e2e-patterns.md` — Playwright patterns and reconnaissance-then-action |
| Decide test granularity | `shared/test-planning.md` — when to combine vs split tests |
| **Understand why the system is structured this way** | **`DESIGN.md` — READ FIRST before changing architecture** |
| Write a new skill | `SKILL.md` — includes contract format and shared primitives guidance |
| Think about security for a feature | `shared/security-lens.md` — design-time questions, implementation patterns, review checklist |
| Run a security audit | `full-security-audit/SKILL.md` — orchestrates phases 1–4 |
| Set up a new project for Claude | `scaffold-project/SKILL.md` — creates project primitives |
| Store a fact or instruction for later | `remember/SKILL.md` — auto-detects project vs global scope |

---

## Conventions

**⚠️ BEFORE making architectural changes** (adding shared docs, modifying primitives, restructuring), **READ `DESIGN.md` FIRST.** It explains WHY the system is structured this way and when to use shared/ vs primitives/.

1. **Skills have contracts.** Each SKILL.md has a `contract:` block in frontmatter declaring tags, state gates, outputs, and next-skills. The router reads these. Don't bypass them.

2. **Shared docs contain general methodology.** `shared/` docs apply to ANY project. Reference them — don't re-implement:
   - `github-ops.md` - GitHub CLI operations
   - `spec-io.md` - Spec file structure and I/O
   - `e2e-patterns.md` - E2E testing patterns (Playwright, reconnaissance-then-action)
   - `test-planning.md` - Test granularity framework (when to combine vs split tests)
   - `security-lens.md` - Security thinking at design, implementation, and review time

3. **Human gates are mandatory.** Gate A (after spec-review) and Gate B (after implementation) require human approval. Never auto-proceed past them.

4. **Confirm before writing to GitHub.** Every `gh` write operation gets a confirmation prompt first. See `shared/github-ops.md`.

5. **State lives in artifacts.** Workflow state is in spec files (`Documents/specs/`) and `SECURITY_PLAN.md`. No separate state file. Read the artifacts to know where you are.

6. **Two state worlds, no crossover.** Feature/bug skills use `state_source: spec`. Security skills use `state_source: security_plan`. They don't share state.

7. **Primitives are living docs.** When you discover something that belongs in a project primitive — a new dependency, a gotcha, a domain term, an architectural constraint — don't let it disappear. Hooked skills run an automatic check at their end via `shared/primitive-updates.md`. Outside of those, a one-line suggestion to the user is fine. The goal: nothing primitive-worthy gets lost in the flow.

---

## Skill Map

```
workflow-router/     ← START HERE. State model, decision trees, skill index.
shared/              ← General methodology. github-ops.md, spec-io.md, e2e-patterns.md, test-planning.md, security-lens.md.
create-spec/         ← Interview. Requirements → spec.
spec-review/         ← Review spec for completeness. [Gate A follows]
plan-tests/          ← Plan tests from approved spec.
write-failing-test/  ← Write failing tests (red phase).
implement-to-pass/   ← Implement to pass tests (green phase). [Gate B follows]
implement-direct/    ← Implement without TDD. [Gate B follows]
diagnose/            ← Bug investigation.
qa-handoff/          ← Post QA checklist. Terminal step.
full-security-audit/ ← Security pipeline orchestrator.
1-security-audit/    ← Security Phase 1: scan.
2-security-critique/ ← Security Phase 2: red team.
3-security-spec/     ← Security Phase 3: failing test.
4-security-fix/      ← Security Phase 4: fix. Loops back to Phase 3.
supabase-security/   ← Supabase security reference (RLS, edge functions, keys).
scaffold-project/    ← One-time project bootstrap. Creates .claude/primitives/ and project-setup.
remember/            ← Store facts into project or global context. Auto-detects scope.
```
