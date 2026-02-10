@echo off
REM Run this as Administrator to create symlinks
REM Right-click > Run as Administrator

echo Creating symlinks for skills...

set SKILLS_SOURCE=%~dp0
set SKILLS_SOURCE=%SKILLS_SOURCE:~0,-1%

REM Create .agents directory if needed
if not exist "%USERPROFILE%\.agents" mkdir "%USERPROFILE%\.agents"

REM Create symlink for agents
if exist "%USERPROFILE%\.agents\skills" (
    echo Backing up existing .agents\skills...
    move "%USERPROFILE%\.agents\skills" "%USERPROFILE%\.agents\skills_backup_%RANDOM%"
)
mklink /D "%USERPROFILE%\.agents\skills" "%SKILLS_SOURCE%"
if %ERRORLEVEL% EQU 0 (
    echo [OK] Created .agents\skills symlink
) else (
    echo [ERROR] Failed to create .agents\skills symlink
)

REM Create .cursor directory if needed
if not exist "%USERPROFILE%\.cursor" mkdir "%USERPROFILE%\.cursor"

REM Create symlink for cursor
if exist "%USERPROFILE%\.cursor\rules" (
    echo Backing up existing .cursor\rules...
    move "%USERPROFILE%\.cursor\rules" "%USERPROFILE%\.cursor\rules_backup_%RANDOM%"
)
mklink /D "%USERPROFILE%\.cursor\rules" "%SKILLS_SOURCE%"
if %ERRORLEVEL% EQU 0 (
    echo [OK] Created .cursor\rules symlink
) else (
    echo [ERROR] Failed to create .cursor\rules symlink
)

echo.
echo Done! Check the results above.
pause
