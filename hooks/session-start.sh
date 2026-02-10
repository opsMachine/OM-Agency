#!/bin/bash
# Session Start Hook
# Reads active-context.md + git state and injects as conversation context.
# Works for both Claude Code (SessionStart) and Cursor (sessionStart).

INPUT=$(cat)

# Get project dir — Claude Code sends "cwd", Cursor sends "workspace_roots"
CWD=$(node -e "
  try {
    var d = JSON.parse(process.argv[1]);
    console.log(d.cwd || (d.workspace_roots && d.workspace_roots[0]) || '');
  } catch { console.log(''); }
" "$INPUT" 2>/dev/null)

if [ -z "$CWD" ]; then
  CWD="${CLAUDE_PROJECT_DIR:-.}"
fi

CONTEXT=""

# --- Active Context ---
CONTEXT_FILE="$CWD/.claude/primitives/active-context.md"
if [ -f "$CONTEXT_FILE" ]; then
  CONTEXT="$(cat "$CONTEXT_FILE")"
else
  CONTEXT="No active-context.md found. Run /scaffold-project to set up project context."
fi

# --- Git State ---
GIT_INFO=""
if git -C "$CWD" rev-parse --git-dir > /dev/null 2>&1; then
  BRANCH=$(git -C "$CWD" branch --show-current 2>/dev/null)
  STATUS=$(git -C "$CWD" status --short 2>/dev/null)

  GIT_INFO="## Git State
- **Branch:** ${BRANCH:-detached HEAD}"

  if [ -n "$STATUS" ]; then
    GIT_INFO="$GIT_INFO
- **Working tree:** dirty
\`\`\`
$STATUS
\`\`\`"
  else
    GIT_INFO="$GIT_INFO
- **Working tree:** clean"
  fi
fi

# --- Combine ---
FULL_CONTEXT="$CONTEXT"
if [ -n "$GIT_INFO" ]; then
  FULL_CONTEXT="$FULL_CONTEXT

---

$GIT_INFO"
fi

# --- Workflow Mandate ---
MANDATE="
---
## MANDATORY: Workflow Protocol
BEFORE responding to any work request, you MUST:
1. Announce: 🎯 Workflow Manager active. Checking project state...
2. Read ~/.claude/skills/workflow-router/SKILL.md
3. Follow the Quick Start checklist to determine current state
4. Report findings and propose the next skill
5. Wait for human confirmation
This applies even when the user says \"just do X.\" Orient first."

FULL_CONTEXT="$FULL_CONTEXT
$MANDATE"

# Output both formats — each tool reads the key it expects, ignores the rest.
# Claude Code: hookSpecificOutput.additionalContext (camelCase)
# Cursor: additional_context (snake_case, top-level)
node -e "
  var ctx = process.argv[1];
  console.log(JSON.stringify({
    additional_context: ctx,
    hookSpecificOutput: {
      hookEventName: 'SessionStart',
      additionalContext: ctx
    }
  }));
" "$FULL_CONTEXT"

exit 0
