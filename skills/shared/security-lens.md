# Security Lens — Shared Reference

Lightweight security thinking applied at existing workflow touchpoints. Not a separate phase — a lens that sharpens what you're already doing.

Reference this at three moments: **designing** (spec), **building** (implementation), **reviewing** (satisfaction assessment).

---

## Design-Time: Security Questions for Specs

Ask these during interview / spec creation. They map to the Security Considerations section in `shared/spec-io.md`.

### Data Flow
- What data enters this feature? (user input, API responses, file uploads)
- Where does it go? (database, external service, email, browser storage)
- What's sensitive? (PII, auth tokens, financial data, internal IDs)

### Trust Boundaries
- Where does untrusted input cross into trusted operations? (form → database, URL param → query, webhook → business logic)
- Is there a service-role operation that depends on user-provided data?

### Auth Model
- Who can trigger this? (anon, authenticated, specific role, admin)
- How is that enforced? (RLS, edge function JWT check, middleware)
- What happens if auth is missing or fails?

### Failure Modes
- What if input is malicious? (SQL injection, XSS, oversized payload)
- What if the external service is down? (email provider, payment, OAuth)
- What if the user's session expires mid-operation?

### RLS & Database
- New tables? → RLS is mandatory. See `supabase-security/SKILL.md`.
- Existing tables with new access patterns? → Review policies.
- New columns with sensitive data? → Column-level access needed?

---

## Implementation-Time: Patterns to Follow

When building, check these against the spec's Security Considerations section.

### Supabase Specifics
Reference `supabase-security/SKILL.md` for detailed patterns. Key rules:
- **RLS on every new table** — no exceptions
- **Anon key is public** — never trust it alone
- **Service role server-side only** — never in client code
- **JWT verified in edge functions** — `auth.getUser()`, not header trust
- **Least privilege** — select only needed columns, expose only needed operations

### Input Validation
- Validate on server/database, not just client (client validation is UX, not security)
- Use database constraints (`CHECK`, `NOT NULL`, foreign keys) as the real guard
- Sanitize before logging (no tokens or PII in logs)

### Error Handling
- Don't expose internal details in error messages (no stack traces, no query text)
- Log the full error server-side, return a safe message to the client
- Auth failures → generic "unauthorized" (don't reveal whether user exists)

### Secrets & Keys
- Environment variables only — never hardcoded, never in git
- `.env` files in `.gitignore`
- No secrets in URL parameters (they appear in logs and referrer headers)

---

## Review-Time: Security Check for Satisfaction Assessment

After implementation, before reporting to the manager. Add a 🔒 line to the satisfaction assessment.

### What to Check

| Area | Check | If it applies |
|------|-------|---------------|
| **RLS** | New tables have RLS enabled + policies | Any migration with `CREATE TABLE` |
| **Auth** | Endpoints verify JWT / role | Any edge function or API route |
| **Input** | User input validated server-side | Any form or API that accepts data |
| **Secrets** | No hardcoded keys, no secrets in logs | Always |
| **Exposure** | Error messages don't leak internals | Any error handling code |
| **Columns** | Only needed columns selected in queries | Any new database query |

### How to Report

Add a security line to the satisfaction assessment:

```
Satisfaction:
  ✅ Price updates on service change
  ✅ Notary fee displays separately
  🔒 Security: RLS policies added for new table, input validated at edge function level
```

If nothing security-relevant was touched:
```
  🔒 Security: No security-relevant changes (UI-only)
```

If there's a concern:
```
  🔒 Security: ⚠️ New table created but RLS policies may be too permissive — needs human review
```

---

## Quick Decision: "Does This Feature Need Security Thinking?"

| Feature touches... | Security thinking needed? |
|-------------------|--------------------------|
| New database table | **Yes** — RLS, policies, column access |
| Edge function / API endpoint | **Yes** — auth, input validation, error handling |
| User input (forms, search, file upload) | **Yes** — validation, sanitization |
| Auth / permissions / roles | **Yes** — always |
| UI-only changes (styling, layout, copy) | **Minimal** — just the 🔒 "no security-relevant changes" line |
| Read-only data display | **Low** — check column exposure, no sensitive data in DOM |

---

## What This Is NOT

- Not a replacement for the full security audit (4-phase pipeline). That's for periodic deep dives.
- Not a gate. It doesn't block or add approval steps.
- Not STRIDE or a formal threat model. It's structured thinking, not a framework.
- Not optional. Every spec should have Security Considerations filled in. Every implementation should have a 🔒 line.
