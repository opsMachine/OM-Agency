# INTEGRATED INTO v3.1 MASTER PLAN

# Design Sketch: The Middle Road Rebuild

A vision document, not an implementation plan. Captures what we'd build if we started fresh with everything we've learned. Keep on hand — implement when the timing is right.

**Created:** 2026-02-09 | **Status:** Ideation

---

## What We're Solving

The current system (19 skills, 6 shared docs, ~6,745 lines) works but has friction:

| Problem | Root Cause |
|---------|-----------|
| "Cranking the wheel" — constant rework, corrections, "no that's not what I meant", babysitting quality | Agent drifts from intent, makes judgment calls that don't match human expectations, doesn't self-check |
| Agent doesn't use principles unless forced | Principles live in files the agent may not read; procedures are the enforcement mechanism |
| Over-segmented skills | Each workflow step is its own 200+ line file; 80% overlap between implement-direct and implement-to-pass |
| Coordinator/sub-agent overhead | Dispatch, context loss, re-reading, reporting back — all costs of a split that exists for human-shaped reasons |
| Procedures where principles would suffice | "Step 1, Step 2, Step 3" when "think about these things" would produce better results |

The "cranking the wheel" problem is NOT just ceremony — it's the agent producing work that needs correction. The system must reduce rework, not just approvals. This means: better focus, better self-checking, and clearer SOPs for things that genuinely must be done a specific way.

**What works and must survive:**
- Spec as consent artifact (human confirms intent before code)
- Satisfaction assessment (agent self-evaluates honestly)
- Hooks for determinism (injected, not optional)
- Primitives for project memory
- Gates A and B as human checkpoints
- Security lens pattern (principles, not procedures)

---

## Design Principles

1. **Principles for judgment, SOPs for operations.** Not everything is a principle. Security thinking, code quality, when to ask — those are principles. Updating GitHub, reading the spec before building, running tests, committing with conventional format — those are SOPs. A senior dev uses judgment AND follows procedures. The system needs both.

2. **Todo lists as the focus mechanism.** Models natively use todo lists to maintain focus and track progress. This is their built-in programming — lean into it. Every task starts with a todo list derived from the spec/intent. The list IS the focus. Hooks reinforce it.

3. **Hooks for determinism.** Anything non-negotiable gets injected via hooks, not left in files the agent might not read. If it must happen every time, it's a hook.

4. **Risk-proportional ceremony.** Simple tasks flow. Complex tasks get structure. The agent assesses risk; the human can override.

5. **One document to internalize.** The agent reads one playbook, not fifteen skill files. Less navigation = less chance of reading the wrong thing or nothing at all.

6. **Reduce rework, not just approvals.** The goal isn't fewer "yes" clicks — it's fewer "no, fix this" cycles. This means: better self-checking, reading before building, verifying before reporting done, and honest uncertainty signals.

---

## Proposed Architecture

### Three Layers + References

```
┌─────────────────────────────────────────────────┐
│  HOOKS (determinism layer — fires every prompt)  │
│  • Session orientation                           │
│  • Admin checklist (spec status, git state)       │
│  • Risk signals (auth? new tables? payments?)     │
│  • Security non-negotiables                      │
└─────────────────────────────────────────────────┘
         │ injected automatically
         ▼
┌─────────────────────────────────────────────────┐
│  PLAYBOOK (one doc — principles + guidance)      │
│  • How to gather requirements                    │
│  • How to assess a spec                          │
│  • How to implement (TDD and direct, unified)    │
│  • How to think about security                   │
│  • How to self-evaluate                          │
│  • How to hand off                               │
│  ~300-400 lines                                  │
└─────────────────────────────────────────────────┘
         │ read at session start + on-demand by section
         ▼
┌─────────────────────────────────────────────────┐
│  SPEC (consent artifact — scaled to risk)        │
│  • Quick mode: 5-10 line confirmation            │
│  • Full mode: current structured spec            │
│  • Agent proposes mode; human can override        │
└─────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────┐
│  REFERENCES (on-demand, unchanged)               │
│  • github-ops.md (CLI commands are procedures)   │
│  • supabase-security.md (stack-specific ref)     │
│  • e2e-patterns.md (testing patterns)            │
│  • test-planning.md (granularity framework)      │
└─────────────────────────────────────────────────┘
```

### What Stays Separate
- Security audit pipeline (4 phases — specialized, infrequent)
- scaffold-project (one-time setup)
- remember (utility)

---

## Principles vs SOPs: The Critical Distinction

Not everything should be a principle. The current system's problem isn't that it has procedures — it's that it has procedures for things that need judgment, and principles for things that need procedures.

**Principles (guide judgment — the playbook):**
- How to think about security
- How to assess quality and completeness
- When to ask vs. proceed
- How to flag uncertainty honestly
- What "good code" looks like in this stack

**SOPs (must be done exactly — enforced by hooks + todo lists):**
- Read the spec/issue before building anything
- Read existing code before writing new code
- Update GitHub issue status after implementation
- Post implementation notes as issue comment
- Run build/tests before reporting done
- Use conventional commit format
- Include satisfaction assessment in every completion report

The playbook carries the principles. The hooks and todo lists carry the SOPs. The agent doesn't choose whether to follow SOPs — they're injected and tracked.

---

## Todo Lists as the Focus Mechanism

Models naturally use todo lists. This is their built-in way of maintaining focus and tracking progress. Rather than fighting this, the system should lean into it.

**How it works:**
1. Agent receives a task (from spec or direct request)
2. Agent creates a todo list from acceptance criteria + required SOPs
3. Each todo item is worked sequentially with status updates
4. Hooks reinforce: "check your todo list — what's next?"
5. Completion = all todos done + satisfaction assessment

**Why this helps with rework:**
- The todo list makes the agent's plan visible BEFORE it starts building
- The human can catch "that's not what I meant" at the todo stage, not after code is written
- SOPs appear as todo items, so they can't be skipped
- The model's natural programming reinforces focus on one item at a time

**Example todo list for a feature:**
```
- [ ] Read spec and extract acceptance criteria
- [ ] Read existing patterns in affected files
- [ ] Implement criterion 1: {specific criterion}
- [ ] Implement criterion 2: {specific criterion}
- [ ] Run build and verify no errors
- [ ] Verify at least one criterion end-to-end
- [ ] Satisfaction assessment (✅/⚠️/❌ + 🔒)
- [ ] Update spec status → Implemented
- [ ] Report to manager for Gate B
```

The SOPs (read first, build check, verify, update status, report) are baked into every todo list. The principles (how to implement well, security thinking) guide the execution of each item.

---

## The Playbook: What's In It

One document replaces: interview, spec-review, implement-direct, implement-to-pass, qa-handoff, diagnose, security-lens. Not by cramming them together — by extracting the principles from each and dropping the procedural scaffolding.

### Section 1: Understanding the Work (~50 lines)
What the interview skill does, but as principles:
- What problem are we solving and for whom?
- What does done look like? (acceptance criteria)
- What are we NOT doing? (scope fence)
- What could go wrong? (security considerations)
- What assumptions are we making?

Output: a spec (quick or full, based on risk assessment).

### Section 2: Assessing Readiness (~30 lines)
What spec-review does, but as a checklist:
- Are criteria specific and testable?
- Is the scope fence clear?
- Are security considerations filled in meaningfully?
- Are there unanswered questions?

### Section 3: Building (~60 lines)
Merges implement-direct and implement-to-pass:
- Match existing codebase patterns
- Follow the spec's security considerations
- If tests exist, make them pass. If not, build and verify manually.
- Flag concerns as you go — don't silently make bad decisions
- Verify at least one criterion end-to-end

### Section 4: Security Thinking (~40 lines)
The current security-lens.md, embedded:
- Design-time questions (data flow, trust boundaries, auth, failure modes, RLS)
- Implementation patterns (RLS mandatory, JWT verification, input validation)
- Review checklist (the 🔒 line)

### Section 5: Self-Evaluation (~30 lines)
The satisfaction assessment pattern:
- ✅/⚠️/❌ per acceptance criterion
- 🔒 Security posture line
- Verification: what you tested vs. what you couldn't
- Honest uncertainty — don't claim confidence you don't have

### Section 6: Handing Off (~20 lines)
- What QA needs to check (manual criteria from spec)
- What to post to GitHub
- What the human should verify

### Section 7: Investigating Bugs (~40 lines)
What diagnose does:
- Hypothesize → verify → confirm/revise
- Assess impact and code smell
- Simple bugs → fix directly. Complex bugs → full spec.

**Total: ~270 lines.** Versus ~4,200 lines currently in skill files.

---

## Risk-Adaptive Modes

Instead of one pipeline for everything, two modes:

### Lightweight Mode
**When:** UI changes, CSS, copy, simple CRUD, clear intent, user says "just do it"
**Flow:**
```
User describes intent
  → Agent confirms in 3-5 lines ("I'll do X, Y, Z. Building now.")
  → Agent builds
  → Agent shows result + satisfaction assessment
  → Human reviews output (Gate B)
  → Done
```
No spec file. No Gate A. No sub-agent dispatch. Hooks still fire.

### Structured Mode
**When:** New tables, auth/RLS, payments, multi-service, complex logic, user requests it
**Flow:**
```
User describes intent
  → Full spec (interview principles from playbook)
  → Human reviews spec (Gate A)
  → Agent implements (with or without TDD, as appropriate)
  → Agent shows result + satisfaction assessment
  → Human reviews output (Gate B)
  → QA handoff if applicable
```

### Risk Signals (how the agent picks a mode)
| Signal | Mode |
|--------|------|
| Touches auth, RLS, payments | Structured |
| New database tables | Structured |
| Edge functions | Structured |
| Multi-file, multi-service | Structured |
| UI/CSS/copy changes | Lightweight |
| Single-file changes | Lightweight |
| User says "just do it" | Lightweight |
| User says "let's be careful" | Structured |
| Uncertainty about scope | Structured |

Agent proposes the mode. Human can always override.

---

## The Router: Lighter

Current router: 490 lines, dispatch tables, decision trees, sub-agent prompt templates.

New router: ~100-150 lines. Does three things:
1. **Orient** — check git state, spec artifacts, where we left off
2. **Assess risk** — signal scan to propose lightweight or structured mode
3. **Track state** — maintain the spec status / test plan status model (this still works)

The router no longer prescribes exact sequences or dispatches sub-agents with elaborate prompt templates. The playbook handles "how to work." The router handles "where are we."

---

## Hooks: Expanded

Move determinism out of skill files and into hooks that fire automatically.

| Hook | Fires | Injects |
|------|-------|---------|
| `SessionStart` | Once | Orient: load active-context, check git state, read playbook |
| `UserPromptSubmit` | Every prompt | "Check your todo list. What's the current item? Have you completed all admin from the last item? Are you about to do work you should confirm first?" |
| `PreCommit` (new) | Before git commit | Security quick-check: no hardcoded secrets, no service role in client, RLS on new tables |

The key insight: hooks are **injected determinism**. The agent doesn't choose to follow them — they're appended to every prompt. This is more reliable than "read this file and follow it."

The UserPromptSubmit hook specifically reinforces the todo list as the focus mechanism. Every prompt, the agent is reminded: what are you working on, have you finished the last thing, what's next. This is the anti-drift mechanism — not a procedure manual, but a persistent nudge toward the plan.

---

## Sub-Agents: When They Earn Their Keep

| Use Sub-Agent | Don't Use Sub-Agent |
|---------------|---------------------|
| Bug diagnosis (exploratory, benefits from focused scope) | Implementation (needs full context) |
| Security audit phases (isolated pipeline) | Test writing (needs deep codebase understanding) |
| Spec review (read-only, fast model OK) | QA handoff (simple formatting task) |

The main agent does most work directly, holding full context. Sub-agents are for genuinely independent, parallelizable work — not for every step of a sequential pipeline.

---

## What This Costs Us

Honest tradeoffs:

| Gain | Risk |
|------|------|
| Less ceremony, faster flow | Agent may drift without step-by-step procedures |
| Principles produce better judgment | Principles are only as good as the agent's ability to internalize them |
| Risk-adaptive modes reduce friction | Risk assessment itself could be wrong |
| Fewer files, less navigation | One large doc may be harder to maintain than small focused ones |
| Main agent holds context | Main agent context window fills faster |

The fundamental bet: **hooks + principles + risk-adaptive gates** can produce the same reliability as **procedures + mandatory gates + sub-agent dispatch**.

This is an empirical question. We'd need to try it and see where reliability breaks, then add structure back only where it actually fails.

---

## Migration Path (If We Do This)

Not a rewrite. Incremental tightening.

1. **Write the playbook** alongside existing skills. Don't delete anything yet.
2. **Expand hooks** — add the risk-signal assessment and the pre-commit check.
3. **Try lightweight mode** on a few simple tasks. See if quality holds without the full pipeline.
4. **Consolidate skills** — merge implement-direct and implement-to-pass first (most overlap). Then fold spec-review into the playbook.
5. **Slim the router** — remove dispatch tables as skills collapse. Keep the orient + state-track functions.
6. **Deprecate** individual skill files as the playbook proves reliable. Don't delete until confident.

Each step is independently reversible. If lightweight mode produces bad results, re-enable structured mode for everything. If the playbook misses things, add the procedure back as a section.

---

## Open Questions

- **Can hooks carry enough context?** The UserPromptSubmit hook is currently ~80 words. How much can we inject before it becomes noise?
- **Will the agent actually follow principles?** We've seen it ignore files. Hooks help, but the playbook sections between hooks are still voluntary reading.
- **Is the risk assessment reliable?** If the agent mis-classifies a complex change as simple, we lose the protection of structured mode.
- **Does this work across models?** Haiku might need more procedure than Opus. The playbook might need to be model-aware.
- **What's the right spec weight for lightweight mode?** Three lines? Five? A template? Or just a natural language confirmation?
- **How much SOP can we bake into todo templates?** If every task generates a todo list with SOPs built in, how standard can those templates be before they become rigid?
- **Does the todo list visible enough to prevent rework?** If the human sees the todo list before code starts and says "that's wrong," we've caught it early. But will they actually look?
- **What's the testing story?** The agent sometimes cheats on tests (writes tests that pass trivially). Is this a principle problem (doesn't understand the goal) or an SOP problem (needs a specific "verify test actually fails first" step)?

---

## The North Star

The system we're heading toward: an agent that works like a senior developer who knows the codebase, follows established patterns, thinks about security by default, asks when genuinely uncertain, and shows its work for review. Not a factory worker following a procedure manual — a colleague who shares your standards and earns trust over time.

But even senior devs follow processes. They update tickets. They read the requirements before coding. They run the tests. They don't skip code review. The difference: they do these things because they understand WHY, not because a checklist forces them to. And when they need to focus on a complex task, they make a list and work through it.

The playbook is how that colleague was onboarded. The todo list is how they stay focused. The hooks are the team norms nobody skips. The spec is the handshake before starting. The gates are the code review before merging.

Everything else is scaffolding — useful while trust is being built, removable as it's earned. But the SOPs stay. Process isn't the enemy. Mindless process is.
