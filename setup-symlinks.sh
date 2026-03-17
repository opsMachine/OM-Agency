#!/usr/bin/env bash
# Setup symlinks so OM-Agency is the global source of truth for AI dev.
# Run from repo root: ./setup-symlinks.sh
#
# Creates:
#   ~/.claude/skills   -> $REPO/skills
#   ~/.claude/agents   -> $REPO/agents
#   ~/.cursor/rules    -> $REPO/skills   (Cursor global rules = same skills)
#   ~/.agents/skills   -> $REPO/skills   (optional; for other agents)
#   ~/.cursor/mcp.json -> $REPO/mcp.json
#   ~/.claude/mcp.json -> $REPO/mcp.json

set -e
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS="$REPO/skills"
AGENTS="$REPO/agents"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

link_to_repo() {
    local target="$1"
    local source="$2"
    local label="${3:-$target}"

    if [[ -L "$target" ]]; then
        local dest
        dest=$(readlink -f "$target" 2>/dev/null || readlink "$target")
        if [[ "$dest" == "$source" ]]; then
            echo -e "   ${GREEN}✓${NC} $label already points to repo."
            return
        fi
        echo -e "   ${YELLOW}↻${NC} $label pointed elsewhere; replacing."
        rm "$target"
    elif [[ -e "$target" ]]; then
        local backup="${target}.backup-$(date +%s)"
        echo -e "   ${YELLOW}📦${NC} Backing up existing $label to $backup"
        mv "$target" "$backup"
    fi

    mkdir -p "$(dirname "$target")"
    if ln -s "$source" "$target" 2>/dev/null; then
        echo -e "   ${GREEN}🔗${NC} $label → repo"
    else
        echo -e "   ${RED}✗${NC} Failed to create $label (try: ln -s $source $target)"
        return 1
    fi
}

echo -e "${BLUE}🔌 OM-Agency: linking ~/.claude and ~/.cursor to this repo${NC}"
echo "   Repo: $REPO"
echo ""

link_to_repo "$HOME/.claude/skills" "$SKILLS" "~/.claude/skills"
link_to_repo "$HOME/.claude/agents"  "$AGENTS" "~/.claude/agents"
link_to_repo "$HOME/.cursor/rules"   "$SKILLS" "~/.cursor/rules"
link_to_repo "$HOME/.agents/skills"  "$SKILLS" "~/.agents/skills"

# MCP config: single source of truth in repo root
link_to_repo "$HOME/.cursor/mcp.json" "$REPO/mcp.json" "~/.cursor/mcp.json"
link_to_repo "$HOME/.claude/mcp.json" "$REPO/mcp.json" "~/.claude/mcp.json"

echo ""
echo -e "${GREEN}Done.${NC} Claude Code and Cursor now use this repo as the global source of truth."
echo "   Edit skills/ and agents/ here; changes apply everywhere."
