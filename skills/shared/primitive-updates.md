# Primitive Updates

Shared end-of-skill procedure. Hooked skills reference this at their end to catch discoveries that belong in project primitives. Lightweight — scan for signals, propose if found, skip silently if not.

---

## Pre-check

If `.claude/primitives/` does not exist in the current project, skip entirely. Don't mention primitives.

---

## How It Works

1. **Scan for signals.** Each hooked skill specifies which signals to watch (see the hook line at the end of that skill). Only check those — don't read all primitives speculatively.

2. **If no signals found:** Stop. Don't mention primitives at all. Zero friction for the common case.

3. **If signals found:** Read only the relevant primitive file(s). Then propose updates one at a time:

> **Primitive update:** `.claude/primitives/<file>` → **<Section>**
> `<proposed addition, 1-2 lines>`
> Update? (yes / skip)

4. **If user says yes:** Write it. Follow the same rules as `/remember` — append, don't replace. Match existing format (table row, bullet, etc.). Update `**Last Updated:**` date if the file has one.

5. **If user says skip:** Move on. No follow-up.

---

## Signal Lists (v3.1)

Each hooked skill states its signals inline. Reference table:

| Skill | Watch for |
|---|---|
| `build` | New/changed packages in package.json. New scripts. New directories in src/. |
| `diagnose` | "Don't do X" discoveries. Non-obvious system behavior. Domain terms encountered during investigation. |
| `understand` | Domain terms or acronyms that surfaced during requirements gathering. |
| `deliver` | Decisions made during testing or QA review. |
| `4-security-fix` | Code that must not be refactored. Architectural constraints revealed by the fix. |

---

## Where Discoveries Route

Use the same classification as `/remember`:

| Discovery | Target | Section |
|---|---|---|
| New dependency or tool | `stack.md` | Key Dependencies or Relevant section |
| New or changed script | `local-dev.md` | Scripts |
| "Don't do X" / gotcha | `local-dev.md` | Common Gotchas |
| Domain term or acronym | `glossary.md` | (add row) — only if file exists |
| Architectural constraint | `architecture.md` | What NOT to Change Without Thinking — only if file exists |
| Decision made | `active-context.md` | Recent Decisions |

---

## What NOT to Do

- Don't read all primitives. Only the file relevant to the signal.
- Don't propose updates for things already documented in that file.
- Don't batch proposals. One at a time.
- Don't interrupt the user if nothing was discovered. Silence is the default.
