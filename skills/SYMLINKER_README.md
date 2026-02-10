# Skill Symlinker

Creates symbolic links so Cursor, Gemini, and ChatGPT can all use the same skills from `~/.claude/skills`.

## Requirements

On Windows, creating symbolic links requires either:
1. **Administrator privileges** (recommended), OR
2. **Developer Mode** enabled + restart (Settings > Update & Security > For developers > Developer Mode)

**Note:** Even with Developer Mode enabled, you may need to restart Windows or run as Administrator.

## Quick Start (Easiest Method)

### Option 1: Run Batch File as Admin (Recommended)
1. Right-click `create-symlinks-admin.bat`
2. Select "Run as Administrator"
3. Done!

### Option 2: PowerShell as Admin
```powershell
# Right-click PowerShell > Run as Administrator, then:
cd ~/.claude/skills
powershell -ExecutionPolicy Bypass -File skill-symlinker.ps1
```

### Option 3: Manual Commands (Run as Admin)
Open Command Prompt or PowerShell as Administrator, then:
```cmd
mklink /D "%USERPROFILE%\.agents\skills" "%USERPROFILE%\.claude\skills"
mklink /D "%USERPROFILE%\.cursor\rules" "%USERPROFILE%\.claude\skills"
```

## Other Methods

### PowerShell (Normal Mode - May Fail)
```powershell
cd ~/.claude/skills
powershell -ExecutionPolicy Bypass -File skill-symlinker.ps1
```

### Bash (Git Bash / WSL)
```bash
cd ~/.claude/skills
./skill-symlinker.sh
```

### Check Developer Mode Status
```powershell
powershell -ExecutionPolicy Bypass -File check-dev-mode.ps1
```

## What It Does

The script creates symlinks from:
- `~/.agents/skills` → `~/.claude/skills` (for ChatGPT and other agents)
- `~/.cursor/rules` → `~/.claude/skills` (for Cursor global rules)
- `~/.gemini/skills` → `~/.claude/skills` (for Gemini - uncomment in script if needed)

**Note:** `~/.claude/skills` is the source location, so it's not symlinked to itself.

## Troubleshooting

### Permission Denied
- Run PowerShell as Administrator, OR
- Enable Developer Mode in Windows Settings

### Symlinks Not Working
- Verify Developer Mode is enabled: Settings > Update & Security > For developers
- Check if symlinks exist: `Get-Item ~/.agents/skills` should show `LinkType: SymbolicLink`
- Manually create symlink: `New-Item -ItemType SymbolicLink -Path "~/.agents/skills" -Target "~/.claude/skills"`

### Path Issues
- The script automatically detects the correct paths
- Make sure you're running it from the `~/.claude/skills` directory
