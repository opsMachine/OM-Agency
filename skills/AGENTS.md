# Skills System

A modular skill ecosystem for Claude Code and Cursor. Skills are composable workflow nodes with typed contracts. This file is the entry point — read it first.

---

## Orient Here

| If you need to... | Read this |
|-------------------|-----------|
| **Start a session** | `workflow-router/SKILL.md` — Mandatory orientation |
| Post to GitHub | `shared/github-ops.md` — all `gh` CLI patterns |
| Read or write a spec file | `shared/spec-io.md` — spec structure and I/O |
| Plan or write E2E tests | `shared/e2e-patterns.md` — Playwright patterns |
| Decide test granularity | `shared/test-planning.md` — when to combine vs split |
| **Understand the design** | **`DESIGN.md` — READ FIRST before changing architecture** |
| Think about security | `shared/security-lens.md` — design, implementation, review |
| Run a security audit | `full-security-audit/SKILL.md` — phases 1–4 |
| Set up a project | `scaffold-project/SKILL.md` — creates primitives |

---

## Conventions

1. **Skills have contracts.** Frontmatter declares tags, state gates, and outputs.
2. **Every workflow skill uses Todo-Driven Execution.** Generate a todo list on invocation.
3. **Principles for judgment, SOPs for operations.** Skill docs carry principles; Todos carry SOPs.
4. **Human gates are mandatory.** Gate A (Spec) and Gate B (Implementation) require approval.
5. **State lives in artifacts.** Workflow state is in spec files and `active-context.md`.

---

## Skill Map (v3.1)

```
workflow-router/     ← START HERE. Orientation checklist.
shared/              ← General methodology and references.

[FEATURE/BUG WORKFLOW]
understand/          ← Intake: Requirements + Spec + Review. [Gate A]
test/                ← TDD: Plan + Write failing tests.
build/               ← Implementation: TDD or Direct modes. [Gate B]
deliver/             ← Closure: QA checklist + GitHub sync. Terminal.

[SPECIALIZED]
diagnose/            ← Bug investigation and root cause analysis.
full-security-audit/ ← Security pipeline orchestrator.
1-4-security-*/      ← Security phases (Scan, Critique, Spec, Fix).
supabase-security/   ← Supabase-specific patterns and reference.
scaffold-project/    ← One-time project bootstrap.
remember/            ← Global and project-level fact storage.
```
