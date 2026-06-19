---
name: ops-machine-crm
description: >
  ANY CRM or progress.md write, log call, add contact, pipeline lookup, paste transcript/email.
  Runs lifecycle routing in Step 0 — delivery work goes to progress.md not Won CRM Next Action.
  Query before create. For week view use week-scan not this skill. OM-Repo SKILLS-MAP.md.
---

# Ops Machine CRM Skill

Mitch's CRM lives in Notion. This skill is the agent layer that makes it actually usable —
handling the query-before-write logic, deduplication, and create-vs-update decisions that were
missing from his previous n8n/ClickUp automation.

## Notion Database IDs

| Database | Notion ID | Data Source ID |
|----------|-----------|----------------|
| 👥 Contacts | `33b19fba-015d-8085-9b67-f55896a46171` | `33b19fba-015d-80b0-8bf4-000bd8f6ecdf` |
| 🤝🏽 Deals | `33b19fba-015d-80f8-929e-d371a570d625` | `33b19fba-015d-8024-895e-000b5cf4b801` |

Always use the **data source ID** (collection ID) when creating or updating records.

---

## Data Model

### Contacts
| Field | Type | Notes |
|-------|------|-------|
| Name | Title | Full name |
| Type | Select | Prospect / Client / Partner |
| Partner Funnel Stage | Select | Identified → Intro Made → Active → Referring (only relevant when Type = Partner) |
| Company | Select | Org name — select field, options grow over time |
| Role | Text | Job title / role |
| Relationship / Met at | Text | How Mitch knows them, where they met |
| Last Contact | Date | Last time Mitch had a real touchpoint |
| Next Action | Text | What Mitch intends to do next |
| LinkedIn | URL | Profile URL — enrichment field, populate when available |
| 🤝🏽 Deals (Client) | Relation → Deals | For prospect/client contacts |
| 🤝🏽 Deals (Partner) | Relation → Deals | For partner contacts |

### Deals
| Field | Type | Notes |
|-------|------|-------|
| Name | Title | Deal name (usually "[Client] - [Service]" format) |
| Type | Select | Client / Partnership — used for subgrouping in pipeline view. Client = revenue deal, Partnership = referral/partner development track |
| Stage | Select | Lead → Q Call Booked → Qualified → Proposal Sent → Hourly Funnel → Launching → Won / Lost — leave BLANK for pre-funnel / radar deals where no action is being taken yet. Blank is the default "on my radar" state. **Hourly Funnel** = paid/hourly exploration underway, no commitment yet. **Launching** = proposal accepted, work is starting. **Won** = commercial close (includes active delivery — use Next Action for live work, not Stage). |
| Deal Value | Number | **Meaning depends on deal shape** — see [Deal Value semantics](#deal-value-semantics) below |
| Recurring | Checkbox | **true** = ongoing monthly revenue (MRR). Deal Value = monthly run rate in deal currency. **false** = one-time or hourly-cumulative. |
| Size | Select | Large / Medium / Small — deal size estimate |
| Last Contact | Date | Last touchpoint on this deal |
| Next Action | Text | Next step on this deal |
| Next Action Date | Date | When the next action should happen — populate whenever a real date is known or implied; leave blank if no date is inferable |
| 👥 Contact(s) | Relation → Contacts | Primary contact(s) for this deal |
| 👥 Partner(s) | Relation → Contacts | Partner contact(s) involved in this deal |
| ☑️ Tasks | Relation → Tasks | All tasks linked to this deal |
| ☑️ Next Action | Relation → Tasks | Next/current task only (separate field by design — don't merge) |

**Structural principle:** Contacts are identity records — who someone is, how Mitch knows them, when he last spoke to them. All actionable work (next steps, tasks, dates, follow-ups) lives on Deals. This is intentional. Contacts don't have Next Action Date, task relations, or action-oriented fields because they're not the unit of work — Deals are. If there's no Deal yet and action is needed, create one.

**Important:** The two task relation fields (Tasks and Next Action) on Deals are intentional.
Notion can't filter completed vs. incomplete tasks cleanly, so these two fields act as a
manual workaround. Do not suggest consolidating them.

### Deal Value semantics

`Deal Value` + `Recurring` + `Currency` work together. **`Value (CAD)`** is a formula — don't write to it.

| Shape | Recurring | Deal Value means | When to update |
|-------|-----------|------------------|----------------|
| **Fixed project** | false | Total contract value | At close; rarely after |
| **Recurring retainer / MRR** | true | Monthly run rate (e.g. $2,500/mo) | When commercial terms change |
| **Hourly (no floor)** | false | **Cumulative billed or agreed-to-date** | After each invoice tranche or when Mitch says total accrued |
| **Hourly with monthly target** | true | Target MRR equivalent | Even if actual billing is hourly — note rate in deal body |

**Examples (live as of 2026-06-05):**
- **Structur** — Won, Recurring=true, $2,500 USD/mo (actual billing $125/hr arrears; MRR for pipeline math)
- **Big Lake** — Won, Recurring=false, $1,500 CAD cumulative hourly (bump Deal Value as hours accrue)
- **EFC** — Won, Recurring=false, $3,000 CAD fixed project (Third Wunder channel)

**Stage = Won + active delivery:** Run **launch transition** (engagement-lifecycle). Won = commercial close. **Delivery next actions live in `progress.md`**, not CRM.

---

## Core Workflow: Query Before Write

**This is the most important rule.** Never create a new record without first checking if one exists.

### Step 0 — Route by lifecycle (before any write)

Read OM-Repo [`.claude/skills/engagement-lifecycle/SKILL.md`](engagement-lifecycle/SKILL.md) (in Mitch's OM-Repo checkout) or the copy at `OM-Repo/.claude/skills/engagement-lifecycle/SKILL.md`. Router: `SKILLS-MAP.md`.

1. Resolve deal + `progress.md` path (glob `clients/`, `sales/`, `partnerships/`)
2. Read `lifecycle_phase` from progress frontmatter; infer from CRM Stage if missing
3. **Redirect writes:**
   - `delivery` → update **`progress.md` only**; CRM limited to Deal Value / Recurring
   - `pipeline` / `launch` / `expansion` / `crm_only` → per lifecycle table
4. If Won deal still has live Next Action → propose **freeze** + progress ownership (don't keep updating CRM as project tracker)

### Step 1 — Parse the input
Extract: person name(s), company/org, deal name or context, any dates, any status signals.

### Step 2 — Search Contacts
Use `Notion:search` with the person's name against the Contacts data source:
```
data_source_url: "collection://33b19fba-015d-80b0-8bf4-000bd8f6ecdf"
query: "[person name]"
```

### Step 3 — Search Deals (if deal-relevant)
Use `Notion:search` with deal name or company against the Deals data source:
```
data_source_url: "collection://33b19fba-015d-8024-895e-000b5cf4b801"
query: "[deal name or company]"
```

### Step 4 — Decide: Create, Update, or Ask
| Situation | Action |
|-----------|--------|
| Clear match found | Update the existing record |
| No match found | Create new record |
| Ambiguous (e.g. "Sarah Chen" — two results) | Ask Mitch to confirm before proceeding |
| Contact exists but deal doesn't | Create deal, link to existing contact |
| Neither exists | Create contact first, then deal, then link |

### Step 5 — Write and confirm
After writing, confirm back to Mitch in plain language what was created or updated. Keep it brief.

### Step 6 — Mirror to `progress.md` (when deal state changed)

**Run Step 0 first.** Mirror rules depend on `lifecycle_phase`:

| Phase | Step 6 behavior |
|-------|-----------------|
| `pipeline` | Mirror CRM → progress frontmatter if file exists |
| `launch` | Mirror once + ensure scaffold; run launch transition checklist |
| `delivery` | **Do not mirror Next Action to CRM** — update progress.md only; CRM commercial fields only if Mitch specifies value/recurring |
| `crm_only` | Skip progress mirror |
| `expansion` | New deal in CRM + log line in existing progress.md |

**After any Deal create/update that changes stage, next action, last contact, temperature, or lost reason (pipeline/launch only):**

1. Check for a repo mirror file:
   - `clients/<slug>/progress.md` (search `clients/` by deal name or known slug)
   - `sales/<slug>/progress.md` (pipeline-only engagements)
   - `partnerships/**/progress.md`
2. **If found and phase ≠ delivery:** update YAML frontmatter to match CRM (`stage`, `status`, `next_action`, `next_action_date`, `last_contact`, `temperature`, `updated`, `deal_value`, `recurring` when set). Append one dated line to the **Log** section.
3. **If delivery phase:** update progress.md only; if CRM Next Action was written by mistake, clear it on confirm.
4. **If not found** and deal is active (not blank radar): note in confirmation — *"No progress.md yet — run launch transition?"* Don't create without Mitch confirming unless he explicitly asked to scaffold the engagement.
5. **If frontmatter changed:** refresh that engagement's row in `clients/INDEX.md` (OM-Repo workspace).

Convention: `clients/README.md` (OM-Repo). **Pipeline:** CRM leads. **Delivery:** progress.md leads.

**Skip Step 6** for read-only queries (pipeline lookup, status check, week-scan) with no writes.

## Common Scenarios

### "Add this person to my CRM"
1. Search Contacts for the name
2. If not found: create Contact with whatever info is available, set Type appropriately
3. If found: confirm with Mitch and offer to update fields

### "Log this call / meeting / transcript"
1. Parse the content for: who, what was discussed, any deal context, next steps
2. Search for the contact(s) mentioned
3. Update Last Contact date on the Contact record
4. Update Next Action if next steps were mentioned
5. If a deal was discussed: update the Deal's Last Contact and Next Action too
6. If no deal exists yet but one is implied: ask Mitch if he wants to create one

### "Forward this email"
Treat like a transcript. Extract the sender/recipient, subject/context, any commitments or next steps. Query before writing.

### "What's in my pipeline?"
Fetch Deals, filter by Stage (exclude Won/Lost unless asked). By default summarize Client-type deals first, then Partnership-type separately. Keep it conversational — not a wall of data.

### "What's in my partner pipeline?"
Filter Deals by Type = Partnership. Summarize by Stage.

### "Who should I follow up with?"
Look at Contacts where Last Contact is old or Next Action is populated. Surface the ones that seem stale or have pending actions. Mitch doesn't want a full dump — give him the 3-5 most actionable ones.

### "X booked a call" / "call is booked with X"
If someone books a call and their deal is at blank Stage or Lead, move the deal to "Q Call Booked". Don't ask — just do it and confirm. This is an unambiguous signal.

### Counter-sale handoff (incoming from counter-sale skill)
When the counter-sale skill has finished research and produced a brief, the CRM write protocol is:

1. **Search Contacts** for the person — confirm no duplicate exists
2. **Check Company field options** — if their company isn't in the select list yet, add it via `notion-update-data-source` before creating the contact (include all existing options + new one)
3. **Create Contact** — Name, Type: Prospect, Company, Role, LinkedIn, Relationship/Met at: "LinkedIn cold outreach", Last Contact: today, Next Action: "Accept call, run counter-sale script"
4. **Create Deal** — Name format: "[Company] - Sales Process Automation", Type: Client, Stage: blank (pre-funnel), Next Action: "Run counter-sale on [call type] call"
5. **Link** the Deal to the Contact via "👥 Contact(s)"
6. **Paste the counter-sale brief** (research summary + hypotheses + call script notes) into the Deal body as page content
7. Confirm back in one line: "Added [Name] as Prospect, created [Deal name], brief is in the deal."

This handoff is automatic — don't ask Mitch to confirm each step. Do it all, then report.

### "What's the status of [person/deal]?"
Fetch the record and summarize in plain language. Don't just dump fields — tell him what matters.

---

## Create/Update Field Guidance

### Next Action Date rule (Deals only)
`Next Action Date` exists on Deals only — not on Contacts. All action tracking lives on the Deal.

Whenever you write or update a **Next Action** (text) on a Deal and a real date is known or clearly implied (e.g. "follow up Thursday", "call booked for the 15th", "check back end of month"), also set **Next Action Date**. This is what triggers Notion reminders at 9:00 AM Toronto time on the day of.

Use the expanded date field syntax:
- `date:Next Action Date:start` → ISO-8601 date string (e.g. `2026-04-15`)
- `date:Next Action Date:end` → leave NULL (single date, not a range)
- `date:Next Action Date:is_datetime` → `0` (date only, not datetime)

Rules:
- If no date is inferable, **leave Next Action Date blank** — don't default to today or guess
- If a date is explicitly stated, always populate it — this is not optional
- If a next action is completed or cleared, also clear the Next Action Date

### When creating a Contact
- Always set Name and Type at minimum
- **Type inference rule:** Default to Prospect unless Mitch explicitly uses words like "partner", "referral source", or "collaboration". "Add X and ping them about Y" = Prospect. Don't infer Partner from context alone.
- Set Partner Funnel Stage only if Type = Partner
- Don't leave Company blank if you know it — if the company isn't already a select option, **add it first** using `notion-update-data-source` with `ALTER COLUMN "Company" SET SELECT(...)` including all existing options plus the new one, then set it on the contact
- Last Contact = today if this came from an active conversation
- Add LinkedIn URL if provided — don't chase it if not

### When creating a Deal
- Name format: "[Company/Person] - [Service or Context]" (e.g. "Acme - AI Jumpstart")
- Always set **Type**: Client for revenue deals, Partnership for referral/partner development
- Default Stage to "Lead" unless context says otherwise — leave blank for pre-funnel
- Always link to at least one Contact if one exists
- Link via "👥 Contact(s)" for clients/prospects, "👥 Partner(s)" for partners

### Relation linking
To link a Deal to a Contact (or vice versa), you need the page URL of the target record.
Use the URL returned from search or fetch results.

---

## Tone and Interaction Style

Mitch built this CRM to be usable — not to be another system that collects dust.

- Be brief in confirmations. "Added Sarah Chen as a Prospect, linked to Acme deal." Not a paragraph.
- When something's ambiguous, ask one question. Not three.
- If Mitch pastes a wall of text, extract what's useful and tell him what you pulled. Don't ask him to clean it up first.
- Never suggest adding more fields or complexity unless Mitch asks. The model is intentionally lean.
- If a deal or contact doesn't exist and the context is thin, create a minimal record and say so. He can fill it in later.

---

## What NOT to do

- Don't create duplicate contacts. Always search first.
- Don't merge the two task relation fields on Deals — they're separate by design.
- Don't add new columns or schema changes without being asked — **except** `Recurring` (checkbox on Deals, added 2026-06-05) which is now part of the model.
- Don't over-report. A one-liner confirmation is almost always enough.
- Don't ask Mitch to format his input before you'll process it. Take the raw thing and work with it.
