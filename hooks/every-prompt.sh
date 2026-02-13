#!/bin/bash
# Prompt Orientation Hook
# Injects brief workflow awareness reminder on every user prompt.
# Context-aware: detects whether you're in a product project (coordinator mode)
# or the skills repo itself (meta/builder mode).

# Detect if we're in the skills repo (meta path)
if [[ "$PWD" == *".claude/"* ]] || [[ "$PWD" == *".claude-worktrees/skills"* ]]; then
  cat <<'HOOK_JSON'
{
  "additionalContext": "## Context: Skills System (Meta Path)\nYou are editing the skill system itself. You work directly — no sub-agent dispatch needed.\nBefore responding: (1) What deliverable am I working on? (2) Have I synced any tracking docs?"
}
HOOK_JSON
else
  cat <<'HOOK_JSON'
{
  "additionalContext": "## Workflow Check\nBefore responding: (1) What phase/step am I in? (2) Am I about to do work I should dispatch? (3) Have I completed all admin from the last step?\n\nPending admin checklist — skip if already done:\n- [ ] Spec status updated?\n- [ ] GitHub issue status updated? (dispatch sub-agent for writes)\n- [ ] active-context.md synced?\n\nYou are a coordinator. Read → Route → Sync. Don't investigate code or write to GitHub directly."
}
HOOK_JSON
fi

exit 0
