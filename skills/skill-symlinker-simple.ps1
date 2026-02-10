# PowerShell version of skill-symlinker for Windows
# Creates symlinks so Cursor, Gemini, and ChatGPT can use the same skills

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$AgencyRepo = Split-Path -Parent $ScriptDir
$SkillsSource = Join-Path $AgencyRepo "skills"

Write-Host "Wiring Global Agents to Agency Brain..." -ForegroundColor Cyan
Write-Host "Source: $SkillsSource"

function Link-Global {
    param(
        [string]$TargetDir,
        [string]$AgentName
    )

    if ($TargetDir -eq $SkillsSource) {
        Write-Host "[OK] $AgentName : Already at source location" -ForegroundColor Green
        return
    }

    $ParentDir = Split-Path -Parent $TargetDir
    if (-not (Test-Path $ParentDir)) {
        Write-Host "[INFO] Creating parent directory: $ParentDir" -ForegroundColor Yellow
        try {
            New-Item -ItemType Directory -Path $ParentDir -Force | Out-Null
        } catch {
            Write-Host "[WARN] Skipping $AgentName : Failed to create parent dir" -ForegroundColor Yellow
            return
        }
    }

    if (Test-Path $TargetDir) {
        $Item = Get-Item $TargetDir -Force -ErrorAction SilentlyContinue
        if ($Item.LinkType -eq "SymbolicLink") {
            $CurrentSource = $Item.Target
            $SkillsSourceAbs = (Resolve-Path $SkillsSource).Path
            if ($CurrentSource -eq $SkillsSourceAbs -or $CurrentSource -eq $SkillsSource) {
                Write-Host "[OK] $AgentName : Already wired correctly" -ForegroundColor Green
                return
            } else {
                Write-Host "[INFO] $AgentName : Updating link" -ForegroundColor Yellow
                Remove-Item $TargetDir -Force
            }
        } else {
            Write-Host "[INFO] Backing up existing $AgentName folder" -ForegroundColor Yellow
            $BackupName = "${TargetDir}_backup_$(Get-Date -Format 'yyyyMMddHHmmss')"
            try {
                Move-Item -Path $TargetDir -Destination $BackupName -Force
                Write-Host "[OK] Backed up to: $BackupName" -ForegroundColor Green
            } catch {
                Write-Host "[WARN] Skipping $AgentName : Could not backup" -ForegroundColor Yellow
                return
            }
        }
    }

    try {
        New-Item -ItemType SymbolicLink -Path $TargetDir -Target $SkillsSource -Force | Out-Null
        Write-Host "[OK] $AgentName : Wired to Repo" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Failed to create symlink for $AgentName" -ForegroundColor Red
        Write-Host "Try running PowerShell as Administrator, or enable Developer Mode" -ForegroundColor Yellow
        Write-Host "Error: $_" -ForegroundColor Red
    }
}

Write-Host "[OK] Claude Code: Skills already at source location" -ForegroundColor Green

$AgentsDir = Join-Path $env:USERPROFILE ".agents"
Link-Global -TargetDir (Join-Path $AgentsDir "skills") -AgentName "Local Agents / ChatGPT"

$CursorDir = Join-Path $env:USERPROFILE ".cursor"
Link-Global -TargetDir (Join-Path $CursorDir "rules") -AgentName "Cursor Global Rules"

Write-Host ""
Write-Host "Done. All agents now share the same brain." -ForegroundColor Green
Write-Host "To update skills: Edit files in this repo."
Write-Host "To add new skills: Add folders to ./skills/ here."
