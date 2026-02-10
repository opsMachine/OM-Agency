#!/bin/bash

# --- CONFIGURATION ---
# The absolute path to the skills directory (The Source of Truth)
# Script is in skills/, so get parent for repo root, then skills is the source
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
AGENCY_REPO="$( cd "$SCRIPT_DIR/.." && pwd )"
SKILLS_SOURCE="$AGENCY_REPO/skills"

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🔌 Wiring Global Agents to Agency Brain...${NC}"
echo -e "   Source: $SKILLS_SOURCE"

# --- HELPER: SYMLINKER ---
# Links the REPO skills folder -> Global Config folder
link_global() {
    local target_dir="$1"  # e.g., ~/.agents/skills
    local agent_name="$2"

    # Skip if target is the same as source (avoid circular symlink)
    if [ "$target_dir" == "$SKILLS_SOURCE" ]; then
        echo -e "   ${GREEN}✓ $agent_name:${NC} Already at source location (no symlink needed)."
        return
    fi

    # 1. Ensure the parent directory exists
    local parent_dir=$(dirname "$target_dir")
    if [ ! -d "$parent_dir" ]; then
        echo -e "   ${YELLOW}📁 Creating parent directory: $parent_dir${NC}"
        mkdir -p "$parent_dir"
        if [ $? -ne 0 ]; then
            echo -e "   ${YELLOW}⚠️  Skipping $agent_name:${NC} Failed to create parent dir $parent_dir"
            return
        fi
    fi

    # 2. Check if the target is already a symlink
    if [ -L "$target_dir" ]; then
        local current_source=$(readlink -f "$target_dir" 2>/dev/null || readlink "$target_dir")
        local skills_source_abs=$(cd "$SKILLS_SOURCE" && pwd)
        if [ "$current_source" == "$skills_source_abs" ] || [ "$current_source" == "$SKILLS_SOURCE" ]; then
            echo -e "   ${GREEN}✓ $agent_name:${NC} Already wired correctly."
            return
        else
            echo -e "   ${YELLOW}↻ $agent_name:${NC} Updating link (was pointing elsewhere)..."
            rm "$target_dir"
        fi
    elif [ -d "$target_dir" ] || [ -f "$target_dir" ]; then
        # 3. If it's a real folder/file, back it up before linking
        echo -e "   ${YELLOW}📦 Backing up existing $agent_name folder...${NC}"
        local backup_name="${target_dir}_backup_$(date +%s)"
        if mv "$target_dir" "$backup_name" 2>/dev/null; then
            echo -e "   ${GREEN}   Backed up to: $backup_name${NC}"
        else
            echo -e "   ${YELLOW}⚠️  Skipping $agent_name:${NC} Could not backup existing directory (may need admin rights)"
            return
        fi
    fi

    # 4. Create the Symlink
    # On Windows, try ln -s first, then fall back to mklink via cmd.exe
    local link_source="$SKILLS_SOURCE"
    local target_parent=$(dirname "$target_dir")
    if [ -n "$target_parent" ]; then
        # Try to create relative symlink
        local rel_source=$(realpath --relative-to="$target_parent" "$SKILLS_SOURCE" 2>/dev/null || echo "$SKILLS_SOURCE")
        link_source="$rel_source"
    fi
    
    # Try Unix-style symlink first
    if ln -s "$link_source" "$target_dir" 2>/dev/null; then
        echo -e "   ${GREEN}🔗 $agent_name:${NC} Wired to Repo."
        return
    fi
    
    # On Windows/Git Bash, try using PowerShell or cmd.exe with mklink
    if [[ "$OSTYPE" == *"msys"* ]] || [[ "$OSTYPE" == *"cygwin"* ]] || [[ -n "$WINDIR" ]]; then
        # Convert paths to Windows format
        local win_target=$(cygpath -w "$target_dir" 2>/dev/null || echo "$target_dir" | sed 's|^/c/|C:\\|;s|/|\\|g')
        local win_source=$(cygpath -w "$SKILLS_SOURCE" 2>/dev/null || echo "$SKILLS_SOURCE" | sed 's|^/c/|C:\\|;s|/|\\|g')
        
        # Try PowerShell first (works better with Developer Mode)
        local script_dir=$(dirname "${BASH_SOURCE[0]}")
        local helper_script=$(cygpath -w "$script_dir/create-symlinks.ps1" 2>/dev/null || echo "$script_dir/create-symlinks.ps1" | sed 's|^/c/|C:\\|;s|/|\\|g')
        if [ -f "$script_dir/create-symlinks.ps1" ]; then
            local ps_result=$(powershell.exe -ExecutionPolicy Bypass -File "$helper_script" -TargetDir "$win_target" -SourceDir "$win_source" 2>&1)
            if [ $? -eq 0 ]; then
                echo -e "   ${GREEN}🔗 $agent_name:${NC} Wired to Repo (via PowerShell)."
                return
            fi
        fi
        
        # Fall back to mklink via cmd.exe
        local mklink_result=$(cmd.exe /c "mklink /D \"$win_target\" \"$win_source\" 2>&1")
        if [ $? -eq 0 ]; then
            echo -e "   ${GREEN}🔗 $agent_name:${NC} Wired to Repo (via mklink)."
            return
        fi
    fi
    
    # If all else fails, provide instructions
    echo -e "   ${YELLOW}⚠️  Failed to create symlink for $agent_name${NC}"
    echo -e "   ${YELLOW}   Options:${NC}"
    echo -e "   ${YELLOW}   1. Run this script as Administrator${NC}"
    echo -e "   ${YELLOW}   2. Enable Developer Mode: Settings > Update & Security > For developers${NC}"
    echo -e "   ${YELLOW}   3. Manually run:${NC}"
    if [[ "$OSTYPE" == *"msys"* ]] || [[ "$OSTYPE" == *"cygwin"* ]] || [[ -n "$WINDIR" ]]; then
        local win_target=$(cygpath -w "$target_dir" 2>/dev/null || echo "$target_dir" | sed 's|^/c/|C:\\|;s|/|\\|g')
        local win_source=$(cygpath -w "$SKILLS_SOURCE" 2>/dev/null || echo "$SKILLS_SOURCE" | sed 's|^/c/|C:\\|;s|/|\\|g')
        echo -e "   ${YELLOW}      cmd /c \"mklink /D \\\"$win_target\\\" \\\"$win_source\\\"\"${NC}"
    else
        echo -e "   ${YELLOW}      ln -s \"$SKILLS_SOURCE\" \"$target_dir\"${NC}"
    fi
}

# --- 1. CLAUDE CODE ---
# Claude looks in ~/.claude/skills by default - this IS the source, so skip symlink
echo -e "   ${GREEN}✓ Claude Code:${NC} Skills already at ~/.claude/skills (source location)"

# --- 2. GENERIC AGENTS / CHATGPT ---
# Your settings.json references ~/.agents/skills.
# If you use other tools that look here, this wires them up.
link_global "$HOME/.agents/skills" "Local Agents / ChatGPT"

# --- 3. CURSOR (Global Rules) ---
# Cursor doesn't have a standardized "global rules folder" that works automatically
# without config, BUT many users link `~/.cursor/rules`.
# If you add "Always look in ~/.cursor/rules" to your Cursor Global System Prompt,
# this link will make it work.
link_global "$HOME/.cursor/rules" "Cursor Global Rules"

# --- 4. GEMINI (if applicable) ---
# Add Gemini support if it uses a specific directory
# Uncomment and adjust path if needed:
# link_global "$HOME/.gemini/skills" "Gemini"

echo -e "\n${GREEN}⚡ Done. All agents now share the same brain.${NC}"
echo -e "   To update skills: Edit files in this repo."
echo -e "   To add new skills: Add folders to ./skills/ here."