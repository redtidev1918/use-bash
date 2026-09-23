---
name: win-to-unix
description: >
  Make your AI agent use Unix shell (bash) instead of getting stuck on PowerShell.
  Writes AGENTS.md with shell selection rules so grep/sed/awk/find work naturally
  in Codex, Claude, or any coding agent on Windows. Also optimizes Defender and
  Git for speed. Use when a Windows user's agent keeps using PowerShell for
  tasks that should use bash.
---

# win-to-unix

Make the agent use bash on Windows. Follow these steps.

## Step 1: Check Git Bash

```powershell
$gitBash = Get-Command bash -ErrorAction SilentlyContinue
if (-not $gitBash) {
    # Try common locations
    $paths = @(
        "$env:USERPROFILE\scoop\apps\git\current\bin\bash.exe",
        "$env:USERPROFILE\scoop\shims\bash.exe",
        "C:\Program Files\Git\bin\bash.exe",
        "D:\Git\bin\bash.exe"
    )
    foreach ($p in $paths) { if (Test-Path $p) { $gitBash = $p; break } }
}
```

If no bash found: `scoop install git` or `winget install Git.Git`

## Step 2: Write AGENTS.md

This is the most important step. Write `~/.codex/AGENTS.md` (create directory if needed). Use the template from `config/AGENTS.md.template`, replacing `{{BASH_PATH}}` with the bash path found in Step 1.

## Step 3: Git config

```powershell
git config --global core.autocrlf false
git config --global core.longpaths true
git config --global core.fscache true
git config --global core.preloadindex true
git config --global core.untrackedCache true
git config --global core.fsmonitor true
git config --global gc.auto 0
```

## Step 4: Defender exclusions (optional, needs admin)

If `config\optimize-admin.ps1` exists, run it elevated:

```powershell
Start-Process powershell -Verb RunAs -ArgumentList '-ExecutionPolicy','Bypass','-File','config\optimize-admin.ps1' -Wait
```

If user declines, skip — not critical.

## Step 5: Verify

```powershell
& "{{BASH_PATH}}" -c "grep --version | head -1"
Test-Path "$env:USERPROFILE\.codex\AGENTS.md"
```

## Step 6: Tell user

```
Done. Your agent will now use bash (grep/sed/awk/find) for Unix tasks
and PowerShell for Windows tasks. Restart terminal for AGENTS.md to take effect.
```

