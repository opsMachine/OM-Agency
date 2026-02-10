---
name: full-security-audit
description: "Run a comprehensive 4-phase security audit on the codebase. Use for periodic security reviews, before major releases, or when touching auth/payments. Orchestrates the 4-phase security pipeline. Say 'security audit' or 'run security pipeline'."
contract:
  tags: [security, orchestrator]
  state_source: security_plan
  inputs:
    params: []
    gates: []
  outputs:
    mutates: []
    side_effects: []
  next: [1-security-audit]
  human_gate: false
---

# Full Security Audit

Orchestrates the 4-phase security pipeline. Each phase is its own skill — this skill tells you when to use the pipeline and how to run it.

## When to Use This (vs. Lightweight Security)

### Use Full Audit When:
- **Periodic review** — Monthly or quarterly security sweep
- **Before major releases** — Catch issues before production
- **Touching sensitive code:** auth/authz, payments, PII, new API endpoints, database schema changes
- **After security incident** — Verify no other vulnerabilities

### Use Lightweight Security When:
- Routine feature development (security questions are built into `/interview`)
- UI-only changes
- Documentation or small bug fixes in non-sensitive code

---

## How to Run

### Option A: Sequential (Recommended)

Run each phase, review output, then proceed:

```
/1-security-audit          → Scan codebase, create SECURITY_PLAN.md
[Review findings]

/2-security-critique       → Red team review, rank the backlog
[Review priorities]

/3-security-spec           → Write failing test for top item
[Confirm test fails correctly]

/4-security-fix            → Fix the vulnerability
[Verify test passes, no regressions]
```

### Option B: Loop (Fix Multiple Issues)

After Phase 4, loop back to Phase 3 for the next item:

```
/1-security-audit → /2-security-critique → [loop]
  → /3-security-spec → /4-security-fix → [next item] →
```

Continue until the backlog is exhausted or you decide to stop.

### Option C: Audit Only (No Fix)

Just identify issues, no implementation:

```
/1-security-audit
/2-security-critique
[Document issues for backlog]
```

---

## Integration with Workflow

**Before major release:**
1. Complete all feature work
2. Run `/full-security-audit` (or start with `/1-security-audit`)
3. Fix critical issues
4. Document remaining issues with timeline
5. Proceed with release

**Periodic review (monthly):**
1. Run `/1-security-audit`
2. Compare with previous `SECURITY_PLAN.md`
3. Prioritize new issues
4. Add to sprint backlog

**After incident:**
1. Run `/1-security-audit` focusing on the affected area
2. Run `/2-security-critique` to catch anything missed
3. Fix all related issues, not just the exploited one

---

## Completion Checklist

- [ ] Phase 1 completed, findings documented in `SECURITY_PLAN.md`
- [ ] Phase 2 reviewed, priorities confirmed
- [ ] Critical issues have failing tests (Phase 3)
- [ ] Critical issues are fixed and tests pass (Phase 4)
- [ ] High issues documented with timeline
- [ ] Medium/Low issues in backlog
- [ ] No regressions in existing tests

---

## Phase Reference

Each phase is a standalone skill. See its SKILL.md for full instructions.

| Phase | Skill | What it does | Output |
|-------|-------|--------------|--------|
| 1 | `/1-security-audit` | Scans codebase for OWASP Top 10 + Supabase-specific issues | `SECURITY_PLAN.md` with Pending findings |
| 2 | `/2-security-critique` | Red team review — removes false positives, ranks by exploitability | Ranked backlog in `SECURITY_PLAN.md` |
| 3 | `/3-security-spec` | Writes failing test for top item | Test file (e.g. `tests/security/exploit_repro.test.ts`) |
| 4 | `/4-security-fix` | Implements fix, marks item DONE | Passing test, item marked DONE |

For Supabase-specific security patterns (RLS, edge functions, keys), see `/supabase-security`.
