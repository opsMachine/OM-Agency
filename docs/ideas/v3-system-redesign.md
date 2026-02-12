# OM-Agency v3.0 — System Redesign Plan

## Context

The OM-Agency skill system (v2.0) works but suffers from a core architectural mismatch: it's modeled as a factory floor (specialized stations, handoffs, foreman) for what is actually a single-agent, single-user workflow. This causes:

- **Context loss** at every sub-agent handoff (the #1 quality issue driving rework loops)
- **Orientation bloat** — 490-line workflow-router + 582-line OPERATIONAL_SYSTEM.md consume context before real work starts
- **Quadruple-redundant** "MANDATORY FIRST ACTION" instructions (symptom of orientation not sticking)
- **No Cursor integration** despite equal usage with Claude Code
- **No persistent memory** between sessions
- **Prose-based instructions** that agents gloss over — no mechanism to enforce step completion or honest review

### The Critical Insight: Built-In Todo Lists Change Everything

**Both Claude Code and Cursor have native todo list features** that we've been underutilizing. These aren't just nice-to-have UI elements — they're a fundamentally better execution mechanism than prose instructions:

- **Agents can't skip review steps** when each verification is a discrete checkbox
- **Orientation is instant** — "where am I?" = check the todo list, not re-read 490 lines
- **Progress is visible** to both agent and user in real-time
- **Resume after interruption** works reliably — the list is the source of truth
- **Cross-tool compatibility** — both platforms support the same primitive

This isn't just an incremental improvement. It's the difference between asking an agent to "follow this 300-line manual" and giving it an explicit, step-by-step execution contract that it must check off.

**Goal:** Shift from a production-line model (7+ handoffs) to a craftsperson model (4 phases, 1 handoff) while preserving test isolation and human gates. **Make native todo lists the primary execution and self-review mechanism**, reducing prose instructions to context and principles. Must work equally well in Claude Code and Cursor.

---

## Core Design Change: Todo-Driven Execution

### The Problem with Prose Instructions

Current skills are 200-300 line instruction manuals. The agent reads them, internalizes what it can, and works from memory. Steps get skipped. Review steps especially get glossed over — "re-read each acceptance criterion and honestly assess" is easy to rush past when it's a paragraph buried in a long document.

**Why prompting alone doesn't work:** When we tell an agent "follow this process," we're relying on the model to hold that process in working memory while also doing the actual work. The longer and more complex the instructions, the more likely the agent is to optimize them away or lose track mid-execution. This is especially true for review steps that feel optional or tedious.

### The Solution: Native Todo Lists as Execution Contracts

**Both Claude Code and Cursor ship with built-in todo list systems.** These are first-class features, not workarounds. We should use them as the primary execution mechanism, not just for tracking.

Each skill becomes a **todo generator** rather than a prose manual. On invocation, the skill:

1. Reads a shorter instruction doc (~80-100 lines) focused on **what** and **why**
2. **Creates a native todo list** with the specific steps for THIS task
3. Works through the list, marking items complete as it goes
4. Review and verification items are explicit todos that cannot be skipped without leaving visible evidence

This gives us:

- **Self-orientation** — the agent checks its todo list to know exactly where it is, not a 490-line manual
- **Honest review** — each verification is a discrete task that must be individually completed, not a vague instruction to "be thorough"
- **Visible progress** — the user can see what's done and what's pending at any time
- **Accountability** — skipped steps are obvious (still unchecked), not invisible (forgotten in working memory)
- **Resumability** — interrupt and resume works naturally; the list is the source of truth
- **Cross-tool compatibility** — both Claude Code and Cursor support the same todo primitives

**The key shift:** From "here are instructions to follow" to "here is an explicit contract of steps you will complete and mark done."

### Two Layers of State

| Layer | Purpose | Mechanism |
|-------|---------|-----------|
| **Strategic** | What phase is this feature in? | Spec file status (Draft → Approved → Implemented) |
| **Tactical** | What am I doing right now, step by step? | Native todo list |

These complement each other. Spec status tells you which skill to invoke. Todos tell you where you are within that skill.

### Skill File Structure (New Pattern)

Each skill SKILL.md now has three sections:

```markdown
## Purpose & Context
~20 lines: What this skill does, when to use it, key principles

## Todo Template
The exact todos to create on invocation (adapted per task).
Includes mandatory review/verification todos.

## Reference
Pointers to shared docs (spec-io.md, github-ops.md, etc.)
Only loaded if needed during execution.
```

Total: ~80-100 lines per skill (down from 200-300).

---

## New Architecture: 4 Phases

```
UNDERSTAND (main context, interactive)
  → Creates todo list: interview steps + self-review checklist
  → Gate A: User approves spec

TEST (sub-agent in Claude Code / instruction-isolated in Cursor)
  → Creates todo list: test planning + writing + failure verification
  → Returns test files on disk

BUILD (main context — carries understand conversation)
  → Creates todo list: implementation steps + per-criterion verification
  → Gate B: User reviews implementation

DELIVER (main context, lightweight)
  → Creates todo list: QA checklist + GitHub updates
```

**What stays unchanged:** diagnose, security pipeline (4 phases), supabase-security, remember, scaffold-project, all shared references, human gates, artifact-based state, contract system.

---

## Phase 1: Create New Consolidated Skills (Todo-Driven)

Create 4 new skill files that replace the 7 current feature-workflow skills. Each generates a todo list on invocation.

### 1a. Create `skills/understand/SKILL.md`
**Replaces:** `create-spec` + `spec-review`
**Runs in:** Main context (interactive, needs conversation)

Content merges:
- Interview steps from `create-spec/SKILL.md` (steps 1-9)
- Self-review checklist from `spec-review/SKILL.md` (completeness checks)
- Spec assembly (from `create-spec/SKILL.md` step 8)
- Gate A presentation (from `workflow-router/SKILL.md` lines 197-205)

Key changes vs current:
- Agent interviews AND reviews in one pass — no handoff between interview and review
- Self-review runs automatically after spec assembly (no separate dispatch)
- If self-review finds gaps, agent asks follow-up questions immediately (no round-trip)
- Gate A presented inline: "Here's the spec. Here's my assessment. Approve?"
- Contract: `next: [test, build]` (user chooses TDD or Direct at Gate A)

**Example todo list generated:**
```
- [ ] Read issue #42 and extract context
- [ ] Interview: Problem framing (what, why, who)
- [ ] Interview: Requirements extraction (done-state, test approach, edge cases)
- [ ] Interview: Scope fencing (non-goals, deferrals)
- [ ] Interview: Security considerations (data, auth, input, RLS)
- [ ] Interview: Constraints & assumptions
- [ ] Resolve open questions
- [ ] Assemble spec at Documents/specs/42-{slug}-spec.md
- [ ] Create/update GitHub issue + add to project board
- [ ] REVIEW: Problem statement is concrete (not vague)
- [ ] REVIEW: Every criterion is assessable (observable outcome, not "handles X appropriately")
- [ ] REVIEW: Non-goals section has at least 1 exclusion
- [ ] REVIEW: Security section populated (or explicitly "N/A — no auth/data/input")
- [ ] REVIEW: No open questions remaining
- [ ] Present spec + assessment → Gate A
```

### 1b. Create `skills/test/SKILL.md`
**Replaces:** `plan-tests` + `write-failing-test`
**Runs in:** Sub-agent (Claude Code) / instruction-isolated (Cursor)

Content merges:
- Test planning from `plan-tests/SKILL.md`
- Test writing from `write-failing-test/SKILL.md`
- References `shared/test-planning.md` and `shared/e2e-patterns.md`

Key changes vs current:
- Single skill plans AND writes tests (no handoff between planning and writing)
- Verification step: run each test, confirm it fails for the right reason
- Cursor section: explicit instruction "You are in test-writing mode. Do NOT write implementation code. Stop after all tests fail correctly."
- Contract: `next: [build]`, `human_gate: false`

**Example todo list generated:**
```
- [ ] Read spec and extract acceptance criteria
- [ ] Search for existing test files (expand before create)
- [ ] Plan: Map each criterion to test location (existing file vs new file)
- [ ] Plan: Classify each test (unit / integration / manual-only)
- [ ] Write test for criterion #1: {description}
- [ ] Verify test #1 fails (run it, confirm failure reason is correct)
- [ ] Write test for criterion #2: {description}
- [ ] Verify test #2 fails
- [ ] ... (one pair per testable criterion)
- [ ] REVIEW: No test is a tautology (assert true, mock-returns-mock)
- [ ] REVIEW: No test uses weak assertions (toBeTruthy when toBe(value) is possible)
- [ ] REVIEW: Manual-only criteria listed for QA checklist (not faked as automated)
- [ ] Update spec Test Plan section with status "Tests Written"
- [ ] Report: test files created, failure reasons, manual criteria list
```

### 1c. Create `skills/build/SKILL.md`
**Replaces:** `implement-to-pass` + `implement-direct`
**Runs in:** Main context (default) — carries full conversation from understand phase

Content merges:
- TDD implementation from `implement-to-pass/SKILL.md`
- Direct implementation from `implement-direct/SKILL.md`
- Satisfaction assessment pattern (shared between both)
- Security lens reference (`shared/security-lens.md`)

Key changes vs current:
- Two modes in one skill, selected at Gate A: `build --tdd` or `build --direct`
- Runs in main context by default (has full conversation history from understand)
- For very large tasks, user can explicitly request sub-agent dispatch
- Satisfaction assessment is mandatory for both modes — each criterion is a separate verification todo
- Gate B presented inline with assessment
- Contract: `next: [deliver]`, `human_gate: true`

**Example todo list generated (TDD mode):**
```
- [ ] Read spec acceptance criteria
- [ ] Read failing test files
- [ ] Identify existing patterns in codebase (match, don't invent)
- [ ] Implement to pass test #1: {criterion}
- [ ] Implement to pass test #2: {criterion}
- [ ] ... (one per failing test)
- [ ] Run full test suite — all tests pass
- [ ] Build/compile succeeds with no errors
- [ ] VERIFY criterion #1: "{exact criterion text}" → ✅ / ⚠️ / ❌
- [ ] VERIFY criterion #2: "{exact criterion text}" → ✅ / ⚠️ / ❌
- [ ] ... (one per acceptance criterion, including manual-only)
- [ ] VERIFY security: RLS/auth/input/secrets check (see security-lens.md)
- [ ] Flag any ⚠️ or ❌ items with explanation
- [ ] Update spec status to "Implemented"
- [ ] Present satisfaction assessment → Gate B
```

**Example todo list generated (Direct mode):**
```
- [ ] Read spec acceptance criteria
- [ ] Identify existing patterns in codebase
- [ ] Plan: What files need to change? What order?
- [ ] Implement criterion #1: {description}
- [ ] Implement criterion #2: {description}
- [ ] ... (one per criterion)
- [ ] Build/compile succeeds
- [ ] Verify at least one criterion end-to-end (run test, check UI, or hit endpoint)
- [ ] VERIFY criterion #1: "{exact text}" → ✅ / ⚠️ / ❌
- [ ] VERIFY criterion #2: "{exact text}" → ✅ / ⚠️ / ❌
- [ ] ... (one per criterion)
- [ ] VERIFY security: RLS/auth/input/secrets check
- [ ] Flag any ⚠️ or ❌ with explanation
- [ ] Update spec status to "Implemented"
- [ ] Present satisfaction assessment → Gate B
```

### 1d. Create `skills/deliver/SKILL.md`
**Replaces:** `qa-handoff`
**Runs in:** Main context (lightweight, fast)

Content from `qa-handoff/SKILL.md` plus:
- GitHub status updates (currently scattered across workflow-router)
- PR linking
- Issue closure guidance

Key change: Absorbs the GitHub-posting responsibility that was split between qa-handoff and the workflow-router manager.

**Example todo list generated:**
```
- [ ] Extract acceptance criteria from spec
- [ ] Format as QA testing checklist (checkbox per criterion)
- [ ] Confirm with user before posting to GitHub
- [ ] Post QA checklist comment to issue #{number}
- [ ] Link PR to issue
- [ ] Update project board status to "QA"
- [ ] Update active-context.md (mark issue as delivered)
```

### Files created this phase:
- `skills/understand/SKILL.md` (~100 lines + todo template)
- `skills/test/SKILL.md` (~80 lines + todo template)
- `skills/build/SKILL.md` (~100 lines + todo template)
- `skills/deliver/SKILL.md` (~60 lines + todo template)

---

## Phase 2: Rewrite Workflow Router (<100 lines)

Current `workflow-router/SKILL.md` is 490 lines. Rewrite to a simple orientation checklist.

### New structure:

```yaml
---
name: workflow-router
description: "Quick orientation. Checks project state, determines current phase, proposes next action."
---
```

**Section 1: Orient (check in order, first match wins)**

| # | Check | You're in | Do this |
|---|-------|-----------|---------|
| 1 | Active todo list exists? | Mid-task | Check todos, resume where you left off |
| 2 | SECURITY_PLAN.md with pending items? | Security path | Follow security pipeline |
| 3 | User mentions bug/error? | Bug path | Run /diagnose |
| 4 | No spec in Documents/specs/? | Fresh start | Run /understand |
| 5 | Spec status: Draft? | Understanding | Continue /understand |
| 6 | Spec status: Approved, no tests? | Ready to build | Ask: TDD or Direct? |
| 7 | Spec status: Approved, tests exist? | Ready to build | Run /build --tdd |
| 8 | Spec status: Implemented? | Gate B | Present for review |
| 9 | PR approved? | Ready to deliver | Run /deliver |

**Section 2: Human Gates (3 mandatory stops)**
- Gate A: After understand → approve spec, choose TDD/Direct
- Gate B: After build → review implementation
- Gate C: After security critique → approve priorities

**Section 3: Cross-tool notes**
- Claude Code: /test dispatches as sub-agent via Task tool
- Cursor: /test runs in main context with isolation instructions
- Both tools: skills generate native todo lists on invocation

That's it. ~80 lines. No sub-agent prompt templates, no narration formats, no dispatch tables. Those belong in the individual skills.

**Key addition:** Row #1 — "Active todo list exists?" This is the most common re-entry point. If the agent has an active todo list, it doesn't need to re-read any skill doc. It just checks its list and resumes. This is how todos solve the orientation problem.

### Files modified:
- `skills/workflow-router/SKILL.md` (rewrite: 490 → ~80 lines)

---

## Phase 3: Cursor Integration

### 3a. Create `.cursor/rules/workflow.mdc`
```yaml
---
description: Workflow orientation - check state before acting
alwaysApply: true
---
```
Contains the same orientation checklist as the workflow-router, adapted for Cursor's format. ~40 lines.

### 3b. Create `.cursor/rules/coding-standards.mdc`
```yaml
---
description: Coding standards and security defaults
alwaysApply: true
---
```
Distilled coding principles: security defaults, no over-engineering, match existing patterns. ~30 lines.

### 3c. Update `skills/scaffold-project/SKILL.md`
- Update the `.cursor/rules/workflow-manager.mdc` template to match new architecture
- Update skill references from old names to new (understand, test, build, deliver)
- Update the `.claude/rules/workflow-manager.md` template similarly

### 3d. Document the symlink setup
Add a `SETUP.md` (or update README) with clear instructions for both tools:
```bash
# Claude Code
ln -s /path/to/OM-Agency/skills ~/.claude/skills

# Cursor
ln -s /path/to/OM-Agency/.cursor/rules ~/.cursor/rules
# Skills are readable via the same ~/.claude/skills symlink
```

### Files created/modified:
- `CREATE: .cursor/rules/workflow.mdc` (~40 lines)
- `CREATE: .cursor/rules/coding-standards.mdc` (~30 lines)
- `MODIFY: skills/scaffold-project/SKILL.md` (update templates)
- `MODIFY: README.md` (setup instructions)

---

## Phase 4: Memory & Orientation

### 4a. Session memory via active-context.md (both tools)
- Update `understand` skill to write session context at end (branch, issue, decisions)
- Update `build` skill to update active-context when implementation completes
- Update `deliver` skill to mark issue as delivered in active-context
- This gives both tools persistent state between sessions

### 4b. Claude Code auto-memory
- Create initial `~/.claude/projects/-home-claude-sandbox-workspace-OM-Agency/memory/MEMORY.md`
- Document key patterns and conventions for the OM-Agency system itself
- This is Claude Code specific but provides cross-session learning

### 4c. Remove orientation redundancy
Currently the "MANDATORY FIRST ACTION" appears in 4 places. Reduce to 1:
- **KEEP:** `CLAUDE.md` (the canonical entry point for Claude Code)
- **REMOVE from:** scaffold-project's `.claude/rules/workflow-manager.md` template (redundant with CLAUDE.md)
- **CURSOR:** `.cursor/rules/workflow.mdc` handles Cursor (created in Phase 3)
- Project AGENTS.md keeps its orientation instruction (it's project-scoped, not redundant)

### 4d. Simplify CLAUDE.md
Current CLAUDE.md (25 lines) is fine in size but references nonexistent paths. Update to:
- Single orientation instruction
- Correct file path for OPERATIONAL_SYSTEM.md (or remove reference since it's being archived)
- Reference new skill names

### Files modified:
- `CLAUDE.md` (simplify)
- Skills updated in Phase 1 already include memory hooks
- `skills/scaffold-project/SKILL.md` (remove redundant rule template)

---

## Phase 5: Documentation Cleanup & Archive

### 5a. Archive old skills
```
mkdir -p docs/archive/skills-v2
mv skills/create-spec    docs/archive/skills-v2/
mv skills/spec-review    docs/archive/skills-v2/
mv skills/plan-tests     docs/archive/skills-v2/
mv skills/write-failing-test  docs/archive/skills-v2/
mv skills/implement-to-pass   docs/archive/skills-v2/
mv skills/implement-direct    docs/archive/skills-v2/
mv skills/qa-handoff     docs/archive/skills-v2/
```

### 5b. Archive OPERATIONAL_SYSTEM.md
```
mkdir -p docs
mv OPERATIONAL_SYSTEM.md docs/design-history.md
```
Add a note at top: "Historical design document. For current system, see skills/workflow-router/SKILL.md and skills/DESIGN.md."

### 5c. Update AGENTS.md
New skill map:
```
workflow-router/     ← START HERE. Orientation checklist.
shared/              ← General methodology.
understand/          ← Interview + spec + self-review. [Gate A follows]
test/                ← Plan + write failing tests. Isolated from build.
build/               ← Implement (TDD or Direct). [Gate B follows]
deliver/             ← QA handoff + GitHub updates. Terminal.
diagnose/            ← Bug investigation.
full-security-audit/ ← Security pipeline orchestrator.
1-4-security-*/      ← Security phases.
supabase-security/   ← Supabase security reference.
scaffold-project/    ← Project bootstrap.
remember/            ← Store facts.
```

### 5d. Update DESIGN.md
Add section explaining v3 design decisions:
- Why craftsperson > factory floor for single-user
- Why test isolation is preserved as the one legitimate handoff
- Why build runs in main context
- Why todo-driven execution > prose instructions
- Cross-tool design constraints

### 5e. Update agent definitions
Consolidate `agents/` directory:
- Remove: spec-review.md, plan-tests.md, write-failing-test.md, implement-to-pass.md, implement-direct.md, qa-handoff.md
- Create: test.md (the one sub-agent definition still needed)
- Keep: diagnose.md, 1-4-security-*.md

### 5f. Fix settings
Update `settings.example.json`:
- Remove `bypassPermissions` note
- Document that this should be applied (not just an example)
- Add note about Cursor equivalent settings

### 5g. Update skill-writer guide
Update `skills/SKILL.md` to reference new architecture:
- Fewer skills, broader capability per skill
- Todo template section is mandatory for workflow skills
- When to create a new skill vs extending an existing one
- Cross-tool considerations

### Files modified/moved:
- `MOVE: OPERATIONAL_SYSTEM.md → docs/design-history.md`
- `MOVE: 7 old skill dirs → docs/archive/skills-v2/`
- `MODIFY: skills/AGENTS.md`
- `MODIFY: skills/DESIGN.md`
- `MODIFY: skills/SKILL.md`
- `MODIFY: agents/` (consolidate)
- `MODIFY: settings.example.json`
- `MODIFY: README.md`
- `REMOVE: agents/spec-review.md, plan-tests.md, write-failing-test.md, implement-to-pass.md, implement-direct.md, qa-handoff.md`
- `CREATE: agents/test.md`

---

## Phase 6: Update Shared References

### 6a. `shared/primitive-updates.md`
Update the list of "hooked skills" from old names to new:
- `implement-direct` → `build`
- `implement-to-pass` → `build`
- `create-spec` → `understand`
- `qa-handoff` → `deliver`

### 6b. `shared/spec-io.md`
No structural changes needed, but verify all references to old skill names are updated.

### 6c. `shared/github-ops.md`
No structural changes needed. Verify references.

---

## Verification

After each phase, the system should be functional:

1. **After Phase 1:** New skills exist and can be invoked directly. Old skills still exist (not yet archived). Both work.
2. **After Phase 2:** Workflow router orients correctly with new skill names. Simple, fast orientation. Todo list check is first orientation step.
3. **After Phase 3:** Cursor users get workflow rules and can read skills via symlinks.
4. **After Phase 4:** Sessions start with orientation. Memory persists between sessions.
5. **After Phase 5:** Old skills archived. Documentation consistent. No broken references.
6. **After Phase 6:** Shared references use correct skill names.

### End-to-end test:
1. Start fresh Claude Code session in a scaffolded project
2. Say "start work on issue #42" → agent should orient, create todo list, start understand
3. Watch agent work through todos — review items should be individually completed
4. Approve spec → agent should ask TDD or Direct
5. Choose TDD → agent should dispatch test sub-agent (with its own todo list), then build in main context (new todo list with per-criterion verification)
6. Approve implementation → agent should run deliver (final todo list)
7. Repeat in Cursor → same flow, same todo pattern, test phase runs in main context with isolation instructions

### Todo-specific verification:
- Agent creates todo list at the start of each skill (not working from memory)
- Review/verification items are individually checked (not batch-completed)
- Agent can resume mid-task by checking its todo list (orientation test: interrupt and ask "where are you?")
- Each ⚠️ or ❌ in the build verification todos produces a visible flag to the user

---

## Summary of Changes

| Metric | v2.0 (current) | v3.0 (proposed) |
|--------|----------------|-----------------|
| Feature workflow skills | 7 | 4 |
| Sub-agent dispatches per feature | 5-7 | 1 (test only) |
| Routing instructions | 490 lines | ~80 lines |
| Skill file size | 200-300 lines | 80-100 lines |
| Orientation mechanism | Read 490-line manual | Check todo list |
| Review enforcement | Prose paragraph | Individual todo items |
| Orientation redundancy | 4 copies | 1 per tool |
| Cursor integration | None | Rules + shared skills + native todos |
| Session memory | None | active-context + auto-memory |
| Context preserved across phases | None (all dispatched) | Full (only test isolated) |
