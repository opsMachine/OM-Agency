#!/bin/bash
# Prompt Orientation Hook
# Injects brief workflow awareness reminder on every user prompt.
# Context-aware: detects whether you're in a product project (coordinator mode)
# or the skills repo itself (meta/builder mode).

# Detect if we're in the skills repo (meta path)
# Skills are now developed in the OM-Agency repo
if [[ "$PWD" == *"OM-Agency"* ]] || [ -f "skills/SKILL.md" ]; then
  CONTEXT="## Context: Skills System (Meta Path)
You are editing the skill system itself. You work directly — no sub-agent dispatch needed.
Before responding: (1) What deliverable am I working on? (2) Have I synced any tracking docs?"
else
  CONTEXT="## Workflow Check
Before responding: (1) What phase/step am I in? (2) Am I about to do work I should dispatch? (3) Have I completed all admin from the last step?

Pending admin checklist — skip if already done:
- [ ] Spec status updated?
- [ ] GitHub issue status updated? (dispatch sub-agent for writes)
- [ ] active-context.md synced?

You are a coordinator. Read → Route → Sync. Don't investigate code or write to GitHub directly."
fi

# Output both formats — each tool reads the key it expects, ignores the rest.
# Claude Code: hookSpecificOutput.additionalContext (camelCase)
# Cursor: additional_context (snake_case, top-level)
node -e "
  var ctx = process.argv[1];
  console.log(JSON.stringify({
    additional_context: ctx,
    hookSpecificOutput: {
      hookEventName: 'UserPromptSubmit',
      additionalContext: ctx
    }
  }));
" "$CONTEXT"

exit 0
