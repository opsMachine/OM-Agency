---
name: 1-security-audit
description: "Phase 1 of security audit pipeline. Scans the codebase for vulnerabilities and creates SECURITY_PLAN.md. Use after /full-security-audit or invoke directly to start a security review. Say 'security audit phase 1' or run '/1-security-audit'."
contract:
  tags: [security, audit, security-phase-1]
  state_source: security_plan
  inputs:
    params: []
    gates: []
  outputs:
    mutates:
      - field: "findings"
        sets_to: "Pending"
    side_effects: ["Creates SECURITY_PLAN.md"]
  next: [2-security-critique]
  human_gate: false
---

# Phase 1: Security Discovery

## What this phase does
Scan the codebase and produce a prioritized findings list. Output lives in `SECURITY_PLAN.md`.

## Instructions

1. **Scan** `src/app` (or configured API folder) for:
   - Mutable endpoints (POST/PUT/DELETE)
   - Missing input validation (e.g. Zod schemas)
   - Authorization gaps (missing auth checks, overly permissive RLS)
   - Exposed secrets or service role keys in client code
   - See `supabase-security/SKILL.md` for Supabase-specific patterns to check

2. **Output:** Create or overwrite `SECURITY_PLAN.md` in the project root. List all findings as `Pending` with severity (Critical / High / Medium / Low) and file location.

3. **Stop.** Display a summary of findings to the user.

The next step is Phase 2: `/2-security-critique`
