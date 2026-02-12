# Operational System v1

> **Purpose:** This document describes the "production line" for quality code - a modular workflow system that optimizes for quality of time spent, not hands-off automation.

**Last Updated:** 2026-02-04
**Version:** 2.0

---

## Philosophy

This system is designed for a human-in-the-loop workflow where:
- AI handles structured work (interviews, spec assembly, TDD implementation)
- Human provides direction, approves specs, and reviews output
- Documents serve as contracts between workflow stages
- GitHub issues serve as the QA-facing interface

**Key Principle:** Optimize for quality of engagement, not quantity of automation.

---

## The Three Workstations

```
INTAKE                             IMPLEMENTATION                       CLOSURE
├── Interview (skill)              ├── CHOOSE PATH:                     ├── QA Handoff
│   ├── Read issue                 │   ├── TDD: plan → test → impl     ├── Link PR
│   └── Update issue               │   └── Direct: impl → verify        └── Close issue
├── Spec Assembly                  └── PR Review (gate)
├── Spec Review (skill)
└── Your Approval (gate)
```

### Workstation 1: INTAKE
**Goal:** Fully understand what needs to be built before writing any code.

| Step | Skill | Output |
|------|-------|--------|
| Interview | `/interview #42` | Requirements extracted |
| Spec Assembly | (part of interview) | `Documents/specs/42-feature-spec.md` |
| Spec Review | `/spec-review path/to/spec.md` | Quality assessment |
| **Human Gate** | You approve | Spec is locked |

### Workstation 2: IMPLEMENTATION
**Goal:** Build exactly what the spec describes.

**Choose your path:**

| Path | When to Use |
|------|-------------|
| **TDD** | Complex logic, security-sensitive, algorithms |
| **Direct** | UI changes, simple CRUD, rapid iteration |

**Path A: TDD (Test-Driven)**
| Step | Skill | Output |
|------|-------|--------|
| Plan Tests | `/plan-tests path/to/spec.md` | Test plan added to spec |
| Write Tests | `/write-failing-test path/to/spec.md` | Failing tests (Red) |
| Implement | `/implement-to-pass` | Code to pass tests (Green) |

**Path B: Direct Implementation**
| Step | Skill | Output |
|------|-------|--------|
| Implement | `/implement-direct path/to/spec.md` | Working code |
| Verify | Manual testing | You confirm it works |

**Human Gate:** You review PR → Code is approved

### Workstation 3: CLOSURE
**Goal:** Hand off to QA and close the loop.

| Step | Skill | Output |
|------|-------|--------|
| QA Handoff | `/qa-handoff #42 path/to/spec.md` | Testing checklist on issue |
| Merge | Manual | PR merged |
| Close | Manual (or auto-close) | Issue closed |

---

## Bug Workflow

Bugs follow a lighter process than features. No spec, no approval gate - just diagnose, test, fix.

```
DIAGNOSIS                          FIX (TDD)                    CLOSURE
├── /diagnose                      ├── /write-failing-test      ├── /qa-handoff (if tracked)
│   ├── GitHub tracked? (ask)      ├── /implement-to-pass       └── Close issue
│   ├── Reproduce                  └── Verify
│   ├── Root cause analysis
│   └── Post to issue (if tracked)
```

### When to Use `/diagnose`

| Situation | Approach |
|-----------|----------|
| Complex bug, unclear cause | `/diagnose` → TDD fix |
| Simple bug, obvious cause | Skip to `/write-failing-test` |
| Tester filed GitHub issue | `/diagnose #42` → posts findings to issue |
| Found during development | `/diagnose` (untracked) → verbal summary |

### Bug Flow (Tracked)

```
1. Tester files issue #42
2. You: "/diagnose #42"
3. AI: Reproduces, investigates, posts diagnosis to issue
4. You: "/write-failing-test" with bug description
5. AI: "/implement-to-pass"
6. You: "/qa-handoff #42"
```

### Bug Flow (Untracked)

```
1. You: "There's a bug where X happens"
2. AI: "/diagnose" (asks if GitHub tracked → No)
3. AI: Reproduces, investigates, summarizes verbally
4. You: "/write-failing-test" with bug description
5. AI: "/implement-to-pass"
6. Done (no QA handoff needed)
```

---

## Skills Reference

> **For programmatic workflow navigation**, see `skills/workflow-router/SKILL.md`. The router contains the canonical state model, skill index with contracts, and executable decision trees. Use it when you need to orient or determine what skill to run next.

### `/diagnose`
**Location:** `~/.claude/skills/diagnose/`
**Triggers:** "diagnose", "investigate bug", "debug this", "why is this broken"

**What it does:**
1. Asks if bug is GitHub-tracked
2. Reproduces the bug
3. Investigates root cause
4. If tracked: posts diagnosis to GitHub issue
5. If untracked: summarizes verbally
6. Hands off to TDD fix workflow

**Input:** Issue number (optional)
**Output:** Diagnosis (issue comment or verbal) → handoff to `/write-failing-test`

---

### `/interview`
**Location:** `~/.claude/skills/interview/`
**Triggers:** "start work on #42", "new feature", "interview me", "requirements"

**What it does:**
1. Reads GitHub issue (if provided) for context
2. Conducts structured interview: Problem → Requirements → Scope → Constraints
3. Assembles spec document in `Documents/specs/`
4. Updates issue with summary comment
5. **Adds issue to project board with sprint status** (Backlog/Current/Next)

**Input:** Issue number (optional)
**Output:** Spec document + issue comment + project board assignment

---

### `/spec-review`
**Location:** `~/.claude/skills/spec-review/`
**Triggers:** "review spec", "check spec", "is this ready?"

**What it does:**
1. Reads spec document
2. Checks completeness (problem, criteria, non-goals, assumptions)
3. Flags gaps and suggests improvements
4. Gives readiness assessment

**Input:** Path to spec document
**Output:** Review report (read-only, doesn't modify)

---

### `/plan-tests`
**Location:** `~/.claude/skills/plan-tests/`
**Triggers:** "plan tests", "test planning", "what tests do we need"

**What it does:**
1. Reads approved spec
2. Searches for existing test files
3. Groups criteria by test location (expand vs create)
4. Maps criteria to specific tests
5. Adds Test Plan section to spec document

**Input:** Path to approved spec
**Output:** Test plan added to spec → handoff to `/write-failing-test`

---

### `/write-failing-test`
**Location:** `~/.claude/skills/write-failing-test/`
**Triggers:** "write failing test", "red phase", "start TDD"

**What it does:**
1. Reads test plan from spec (created by `/plan-tests`)
2. Writes failing tests according to the plan
3. Verifies each test fails for the right reason
4. Updates test plan status to "Tests Written"

**Input:** Path to spec with test plan
**Output:** Failing tests → handoff to `/implement-to-pass`

---

### `/implement-to-pass`
**Location:** `~/.claude/skills/implement-to-pass/`
**Triggers:** "implement to pass", "green phase", "make tests pass"

**What it does:**
1. Reads failing tests
2. Implements minimum code to pass each test
3. Runs tests after each change
4. Stops when all tests pass

**Input:** None (uses current failing tests)
**Output:** Implementation code that passes all tests

---

### `/implement-direct`
**Location:** `~/.claude/skills/implement-direct/`
**Triggers:** "just implement", "implement directly", "skip tests"

**What it does:**
1. Reads approved spec
2. Implements with judgment (flags anything that seems wrong)
3. Asks clarifying questions if needed
4. Produces working code

**Input:** Path to approved spec
**Output:** Working implementation → you verify manually

**Use when:** UI changes, simple CRUD, rapid iteration, features you'll test manually

---

### `/qa-handoff`
**Location:** `~/.claude/skills/qa-handoff/`
**Triggers:** "ready for testing", "qa handoff", "update issue for QA"

**What it does:**
1. Reads spec document
2. Extracts acceptance criteria
3. Formats as QA testing checklist
4. Posts comment to GitHub issue
5. Links PR to issue

**Input:** Issue number + spec path
**Output:** Issue comment with testing checklist

---

### `/supabase-security`
**Location:** `~/.claude/skills/supabase-security/`
**Triggers:** "supabase security", "RLS policies", "supabase best practices"

**What it does:**
- Reference guide for secure Supabase development
- RLS policy patterns and anti-patterns
- Edge function JWT verification
- Service role vs anon key guidance
- Common Supabase security vulnerabilities

**Input:** None (reference skill)
**Output:** Security guidance and patterns

---

### `/full-security-audit`
**Location:** `~/.claude/skills/full-security-audit/`
**Triggers:** "security audit", "full security review", "run security pipeline"

**What it does:**
- Documents when to use heavyweight vs lightweight security
- Orchestrates the 4-phase security pipeline
- Provides checklists for audit completion

**Input:** None
**Output:** Guidance on running the 4-phase audit

---

## GitHub Issue Pattern

**Token-efficient approach:** Issues are read/written minimally. Detailed specs live in the repo.

| Stage | Read from Issue | Write to Issue |
|-------|-----------------|----------------|
| Interview start | Title, description | — |
| Interview end | — | Summary + spec link |
| QA Handoff | — | Testing checklist |

**Issue = QA-facing interface**
- Brief summary of what changed
- Link to spec (for detail)
- Manual testing checklist
- PR link

**Spec = Implementation artifact**
- Full problem statement
- Detailed acceptance criteria
- Non-goals and constraints
- Technical notes

---

## Human Gates

Two approval points prevent runaway AI work:

1. **After Spec Review** → You approve spec before implementation starts
2. **After Implementation** → You review PR before merge

These are intentionally manual. You trigger the next phase.

---

## Security Integration

Security is built into the workflow at multiple levels, not bolted on at the end.

### Lightweight Security (Every Feature)

Built into the standard workflow:

| Stage | Security Activity |
|-------|-------------------|
| **Interview** | Asks about data sensitivity, auth needs, input validation, RLS |
| **Spec** | Security Considerations section captures requirements |
| **Implementation** | OWASP quick check + Supabase-specific checks |
| **Verification** | Security checklist verified before claiming done |

This adds minimal overhead while catching common issues early.

### Heavyweight Security (Periodic/Sensitive)

For deeper security review, use the 4-phase audit pipeline:

```
/1-security-audit     → Scan codebase, identify issues
/2-security-critique  → Red team review, refine priorities
/3-security-spec      → Write failing test for top issue
/4-security-fix       → Fix to pass the test
```

**Or use the wrapper:** `/full-security-audit`

### When to Use Which

| Scenario | Approach |
|----------|----------|
| Normal feature development | Lightweight (built into workflow) |
| Touching auth/authorization | Lightweight + extra scrutiny at PR review |
| Touching payments/financial data | Consider full audit |
| New API endpoints | Lightweight, verify auth checks |
| New database tables | Lightweight, verify RLS policies |
| Monthly/quarterly review | Full audit |
| Before major release | Full audit |
| After security incident | Full audit on affected area |

### Security Skills Reference

| Skill | Purpose |
|-------|---------|
| `/supabase-security` | Supabase-specific best practices (RLS, edge functions, keys) |
| `/full-security-audit` | Orchestrates the 4-phase security pipeline |
| `/1-security-audit` | Phase 1: Scan and plan |
| `/2-security-critique` | Phase 2: Red team review |
| `/3-security-spec` | Phase 3: Write failing security test |
| `/4-security-fix` | Phase 4: Implement fix |

---

## Project Setup

Each project needs:

```
project-root/
└── Documents/
    ├── specs/           # Spec documents go here
    │   └── .gitkeep
    └── templates/
        └── spec-template.md   # Copy from first project or create
```

The spec template should include:
- Problem Statement
- Acceptance Criteria (checkboxes)
- Non-Goals
- **Security Considerations** (data sensitivity, auth, input validation, RLS)
- Assumptions & Constraints
- Technical Notes
- Open Questions Resolved

---

## Typical Session Flow

```
1. You: "Let's work on issue #42"
2. AI: /interview #42
   → Reads issue, asks questions, creates spec

3. You: "Review the spec"
4. AI: /spec-review Documents/specs/42-feature-spec.md
   → Checks completeness, flags gaps

5. You: "Looks good, approved"

6. AI: /plan-tests Documents/specs/42-feature-spec.md
   → Creates test plan, adds to spec

7. You: Review test plan, "looks good"

8. AI: /write-failing-test Documents/specs/42-feature-spec.md
   → Writes failing tests (Red phase)

9. AI: /implement-to-pass
   → Implements code to pass tests (Green phase)

10. You: Review PR, approve
11. AI: /qa-handoff #42 Documents/specs/42-feature-spec.md
    → Posts testing checklist to issue

12. QA tests, you merge, issue closes
```

---

## How to Iterate on This System

### Adding a New Skill
1. Create folder: `~/.claude/skills/skill-name/`
2. Create `SKILL.md` with YAML frontmatter (name, description)
3. Follow patterns from existing skills
4. Restart Claude Code to load
5. Test with natural language triggers
6. Update this document

### Modifying a Skill
1. Edit the `SKILL.md` file
2. Restart Claude Code
3. Test the changes
4. Note what changed in "Version History" below

### Debugging Skill Discovery
If a skill doesn't trigger:
- Check description includes trigger words
- Verify YAML frontmatter is valid
- Restart Claude Code
- Try explicit invocation: `/skill-name`

---

## Version History

### v2.0 (2026-02-04)
- **Modular primitives + contracts + router** — Skills iteration for manager-agent readiness
- New shared primitives: `shared/github-ops.md` (single source for all GitHub CLI patterns), `shared/spec-io.md` (spec file structure and I/O)
- All workflow skills now have `contract:` blocks in frontmatter: tags, state gates, outputs, next-skill declarations
- Duplicated GitHub ops stripped from 5 skills — all point to `shared/github-ops.md`
- New `workflow-router` skill: state model + skill index + executable decision trees. Entry point for manager-agent pattern
- 4 security phases converted from loose `.md` files to proper skill directories with contracts
- `full-security-audit` thinned to orchestrator (phases live in their own skills now)
- `skill-writer` updated with contract writing guidance and shared primitives pattern
- Removed deprecated `/implement-from-spec` references

### v1.8 (2026-01-28)
- **TDD is now optional** - New `/implement-direct` skill
- Two implementation paths: TDD (for complex logic) or Direct (for UI/simple features)
- `/implement-direct` implements with judgment, flags concerns, no tests required
- You choose the path after spec approval

### v1.7 (2026-01-28)
- **Separated test planning from test writing** - New `/plan-tests` skill
- Test planning (analytical) is now isolated from test writing (implementation)
- `/plan-tests` creates test plan and adds it to spec document
- `/write-failing-test` now executes the plan instead of creating it
- `/implement-from-spec` deprecated - redirects to new workflow
- Cleaner flow: interview → spec-review → [approve] → plan-tests → write-failing-test → implement-to-pass

### v1.6 (2026-01-28)
- **GitHub project integration** - Issues automatically added to project board
- Interview skill now adds issues to repo's project
- Asks user for sprint status: Backlog, Current Sprint, or Next Sprint
- Added checklist items for project assignment verification

### v1.5 (2026-01-28)
- **Test grouping and analysis** - Prevents test file sprawl
- Added Step 1.5: Analyze Existing Tests & Group Criteria
- New philosophy: "Expand before create" - add to existing test files first
- New philosophy: "Test behaviors, not criteria" - multiple criteria can share one test
- Search for existing tests before creating new files
- Output test plan showing which files get expanded vs created
- Revised output format to show test files, not individual criteria

### v1.4 (2026-01-28)
- **Skipped tests must fail loudly** - Cannot claim "ready" with skipped tests
- Added Step 0: Verify Test Infrastructure (Supabase, Docker must be running)
- Skipped tests are a BLOCKING failure, not acceptable
- Agent must start Supabase before proceeding

### v1.3 (2026-01-28)
- **Test quality gate added** - Prevents placeholder/fake tests
- Spec template now requires Test Type classification (Unit/Integration/Manual)
- Interview skill asks about testability for each criterion
- `/write-failing-test` has "Meaningful Test Checklist" with 4 quality checks
- Manual criteria go to QA checklist, not automated tests
- Added explicit anti-patterns: no "defer to integration test" comments, no weak assertions

### v1.4 (2026-01-28)
- **Skipped tests must fail loudly** - Cannot claim "ready" with skipped tests
- Added Step 0: Verify Test Infrastructure (Supabase, Docker must be running)
- Skipped tests are a BLOCKING failure, not acceptable
- Agent must start Supabase before proceeding

### v1.2 (2026-01-28)
- Added bug workflow with `/diagnose` skill
- Bug flow: diagnose → TDD fix (lighter than feature flow)
- `/diagnose` asks if GitHub-tracked: posts to issue or summarizes verbally
- No Documents/bugs/ folder - GitHub issue IS the bug report

### v1.1 (2026-01-27)
- Added security integration to workflow
- Interview skill now asks security questions
- Spec template includes Security Considerations section
- implement-from-spec includes OWASP + Supabase security checks
- New skill: `/supabase-security` - Supabase best practices reference
- New skill: `/full-security-audit` - Wrapper for 4-phase security pipeline
- Updated documentation with security guidance

### v1.0 (2026-01-27)
- Initial system created
- Four skills: interview, spec-review, implement-from-spec, qa-handoff
- Documents folder structure
- GitHub issue integration
- Two human gates (spec approval, PR review)

### Future Improvements (Backlog)
- [ ] Chain automation (agent triggers next agent)
- [ ] Learning extraction (capture patterns from completed work)
- [ ] Cost estimation before implementation
- [ ] Automatic issue creation from interview
- [ ] PR template generation from spec
- [ ] Retrospective skill (what went well, what didn't)

---

## Troubleshooting

**Skills not loading:**
- Restart Claude Code
- Check `~/.claude/skills/` for the skill folder
- Verify SKILL.md has valid YAML frontmatter

**Interview not reading issue:**
- Ensure `gh` CLI is authenticated
- Check issue number is correct
- Try `gh issue view #42` manually

**Spec not being created:**
- Verify `Documents/specs/` folder exists
- Check write permissions

**QA handoff not posting:**
- Ensure `gh` CLI is authenticated
- Verify issue exists and is open
- Check for rate limiting

---

## Related Documents

- **~/.claude/CLAUDE.md** - Coding standards and principles
- **~/.claude/skills/** - Skill implementations
- **Project CLAUDE.md** - Project-specific context and active work
