---
name: comedy-db
description: >
  Manages Mitch's Notion comedy writing database. Use this skill whenever Mitch wants to interact
  with his comedy material — creating new bit entries, updating existing bits as material develops,
  reading what's in the database, changing status, or adding notes. Trigger on phrases like:
  "add this to my comedy database", "save this bit", "update the vasectomy bit", "what bits do I have",
  "mark this as ready", "add these lines to that bit about X", "create a new entry for this premise",
  "what's in my comedy DB", or any time Mitch is developing stand-up material and wants it captured
  or retrieved. Also trigger when Mitch pastes raw material mid-conversation and wants it saved.
  Always fuzzy-search before creating — never assume a bit doesn't exist.
---

# Comedy Database Skill

Mitch's comedy writing database lives in Notion. This skill manages reads, creates, and updates
against that database — with fuzzy search to identify existing bits before writing anything.

## Database Details

| Field | ID |
|-------|----|
| Database URL | `https://www.notion.so/10319fba015d80d7bab6f76bf0732aca` |
| Data Source ID | `da3b0767-6837-4e60-b017-39d821c84a99` |

### Schema

| Property | Type | Notes |
|----------|------|-------|
| Name | title | Bit name |
| Notes | text | One-line summary of premise / tone |
| Status | select | `Testable` or `Ready` |
| Tags | multi_select | Ignore — leave blank on all writes |

**Page body** is where the real content lives: full sequence, structure notes, verbatim lines,
callbacks, connected material. Always write rich content to the page body, not just properties.

---

## Core Workflow: Fuzzy Search Before Every Write

**Never create or update without searching first.**

Mitch won't always remember exact bit names. Use broad keyword searches to find candidates,
confirm the match with him, then proceed.

### Step 1 — Search
```
Notion:search
  query: [keyword from bit topic — e.g. "vasectomy", "bus", "sample"]
  data_source_url: "collection://da3b0767-6837-4e60-b017-39d821c84a99"
  page_size: 5
```

### Step 2 — Confirm
If one clear match: *"Found 'The Sample Gauntlet (Vasectomy Bit)' — is that the one?"*
If multiple candidates: surface them briefly and ask.
If no match: confirm you're creating a new entry before proceeding.

### Step 3 — Write and confirm
After writing, confirm in one line what was created or updated.

---

## Common Actions

### Create a new bit entry
1. Search for similar titles/topics first — confirm it doesn't exist
2. Synthesize a clean **Name** from the conversation (descriptive, specific)
3. Write a one-line **Notes** summary (premise + tone, not a full description)
4. Set **Status** to `Testable` by default unless Mitch says otherwise
5. Write rich **page body content** including:
   - Premise summary
   - Sequence / structure (numbered beats)
   - Verbatim lines worth keeping (in a dedicated section)
   - Callback opportunities
   - Connected material (other bits in the same universe)
   - Craft notes if relevant (form, length target, open mic cut guidance)

### Update an existing bit
1. Fuzzy search → confirm the bit
2. Fetch the page to read current content before overwriting anything
3. Make targeted edits: append new lines, update sequence, add callbacks, etc.
4. If status is changing (e.g. Testable → Ready), confirm intent first

### Read / browse the database
1. Search with broad query or fetch the database directly
2. Summarize what's there conversationally — don't dump raw fields
3. Highlight Status if relevant (e.g. "You have 3 Testable bits and 1 Ready")

### Mark a bit as Ready
Confirm: *"Mark [bit name] as Ready?"* — then update Status field.

---

## Page Body Format

Use this structure when creating or significantly updating a bit entry:

```
## 🎯 Premise
[One paragraph — the grounded observation and where it goes]

---

## 🏗️ Sequence
### 1. [Beat name]
[Description of beat, purpose, tone note]

### 2. [Beat name]
...

---

## 💬 Verbatim Lines Worth Keeping
- *"[line]"*
- *"[line]"*

---

## 🔁 Callbacks Available
- [setup] → [callback opportunity]

---

## ✂️ Open Mic Cut ([X] min version)
[What to drop, what to keep, target length]

---

## 🌿 Connected Material
- [Related bit or arc — keep separate]

---

## 📚 Craft Notes
[Form, influences, structural observations]
```

Not all sections are required for every entry — use judgment based on how developed the material is.
A raw premise note doesn't need a full Craft Notes section. A developed bit should have most of them.

---

## Tone and Interaction Style

- Confirm before creating net-new entries: *"Want me to add this as a new bit called X?"*
- Confirm before overwriting substantial existing content
- Read-only actions (browse, search, summarize) fire automatically — no confirmation needed
- Keep confirmations to one line — don't over-explain
- If Mitch pastes raw material mid-conversation, extract the useful bits and say what you pulled
- Never add Tags — leave that field blank on all operations
