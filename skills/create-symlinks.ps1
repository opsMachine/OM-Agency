# Helper script to create symlinks using PowerShell
# This may work better with Developer Mode than Git Bash

param(
    [string]$TargetDir,
    [string]$SourceDir
)

$ErrorActionPreference = "Stop"

try {
    # Ensure parent directory exists
    $ParentDir = Split-Path -Parent $TargetDir
    if (-not (Test-Path $ParentDir)) {
        New-Item -ItemType Directory -Path $ParentDir -Force | Out-Null
    }
    
    # Remove existing if it exists
    if (Test-Path $TargetDir) {
        $Item = Get-Item $TargetDir -Force
        if ($Item.LinkType -eq "SymbolicLink") {
            Remove-Item $TargetDir -Force
        } else {
            $BackupName = "${TargetDir}_backup_$(Get-Date -Format 'yyyyMMddHHmmss')"
            Move-Item -Path $TargetDir -Destination $BackupName -Force
            Write-Host "Backed up to: $BackupName"
        }
    }
    
    # Create symlink
    New-Item -ItemType SymbolicLink -Path $TargetDir -Target $SourceDir -Force | Out-Null
    Write-Host "SUCCESS: Created symlink $TargetDir -> $SourceDir"
    exit 0
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
    exit 1
}
