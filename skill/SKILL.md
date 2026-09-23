---
name: use-bash
description: >
  Make your AI agent use Unix shell (bash) instead of getting stuck on PowerShell.
  Writes AGENTS.md with shell selection rules so grep/sed/awk/find work naturally
  in Codex, Claude, or any coding agent on Windows. Also configures Defender
  exclusions the safe way. Use when a Windows user's agent keeps using PowerShell
  for tasks that should use bash.
---

# use-bash

Make the agent use bash on Windows. Follow these steps in order.

## Step 0: Backup - always run before changing anything

Save the current state so Uninstall can restore the original machine exactly:

```powershell
$backup = "$env:USERPROFILE\.codex\use-bash-backup.json"
if (-not (Test-Path $backup)) {
  $state = [ordered]@{
    timestamp      = (Get-Date).ToString('o')
    userPath       = [Environment]::GetEnvironmentVariable('Path','User')
    agentsMdExists = Test-Path "$env:USERPROFILE\.codex\AGENTS.md"
    bashAliasState = if (Test-Path "$env:USERPROFILE\AppData\Local\Microsoft\WindowsApps\bash.exe") { 'present' } else { 'absent' }
    gitConfig      = @{}
  }
  foreach ($k in 'core.autocrlf','core.longpaths','core.fscache','core.preloadindex','core.untrackedCache','core.fsmonitor','gc.auto') {
    $v = git config --global --get $k 2>$null
    if ($v) { $state.gitConfig[$k] = $v }
  }
  if ($state.agentsMdExists) {
    Copy-Item "$env:USERPROFILE\.codex\AGENTS.md" "$env:USERPROFILE\.codex\AGENTS.md.use-bash-bak" -Force
  }
  $state | ConvertTo-Json -Depth 3 | Set-Content $backup -Encoding UTF8
  Write-Host "Backup saved: $backup"
}
```

## Step 1: Find bash - check MSYS2 FIRST, then Git Bash

```powershell
$bashPaths = @(
  "$env:USERPROFILE\scoop\apps\msys2\current\usr\bin\bash.exe",
  "$env:USERPROFILE\scoop\apps\git\current\bin\bash.exe",
  "C:\Program Files\Git\bin\bash.exe",
  "D:\Git\bin\bash.exe"
)
$gitBash = $bashPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
```

If no bash found: `scoop install msys2` or `scoop install git` or `winget install Git.Git`

IMPORTANT: MSYS2 bash must be checked first. Older versions of this skill only
looked for Git Bash and silently skipped everything when only MSYS2 was installed.

## Step 1.5: Fix PATH - prevent bare `bash` from resolving to WSL

Newer Store-based WSL has no `C:\Windows\System32\bash.exe`. The WSL bash alias
lives in `%LOCALAPPDATA%\Microsoft\WindowsApps\bash.exe`. Check resolution:

```powershell
where.exe bash
```

If it does NOT print the path found in Step 1, fix the user PATH by inserting the
bash directory BEFORE the WindowsApps entry, then optionally rename the WSL
alias `bash.exe` to `bash-wsl.exe` so bare `bash` can NEVER hit WSL. WSL stays
fully usable via the `wsl` command. See the full scripts in the repo README.

PATH insert script:

```powershell
$bashDir = Split-Path $gitBash
$winApps = "$env:USERPROFILE\AppData\Local\Microsoft\WindowsApps"
$userPath = [Environment]::GetEnvironmentVariable('Path','User')
$parts = ($userPath -split ';') | Where-Object { $_ }
$parts = $parts | Where-Object { $_ -ne $bashDir }
$waIdx = [array]::IndexOf($parts, $winApps)
if ($waIdx -ge 0) {
  $parts = @($parts[0..($waIdx-1)]) + $bashDir + @($parts[$waIdx..($parts.Count-1)])
} else {
  $parts = @($bashDir) + $parts
}
[Environment]::SetEnvironmentVariable('Path', ($parts -join ';'), 'User')
```

## Step 2: Write AGENTS.md

Write `~/.codex/AGENTS.md` (create directory if needed). Use the template below,
replacing `{{BASH_PATH}}` with the path found in Step 1. Also write a rescue
section so the agent can recover WSL without asking the user to reboot.

```markdown
# Shell Rules

Default shell: bash. Use PowerShell only for registry, Windows services,
Windows processes, .NET objects, MSI, and UnrealBuildTool.

## Bash path

Primary: {{BASH_PATH}}
Fallback: run bash via PowerShell with the full path above, login shell:
  & "{{BASH_PATH}}" -lc "your command"

If bare `bash` resolves to something else, run `where.exe bash` and report it.

## WSL rescue - run this FIRST when wsl.exe commands hang

Stale wsl.exe processes deadlock WslService; every new wsl.exe then hangs.

1. Stop-Process -Name wsl,wslhost -Force
2. Retry the wsl command. Do NOT reboot first; do NOT uninstall WSL.
3. If WslService itself is wedged, restart elevated: Restart-Service WslService -Force

Never kill vmmem or vmcompute to fix a hang.
```

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

## Step 4: Defender exclusions - NEVER disable real-time protection

Only add scoped exclusions. Disabling real-time protection entirely is a
security regression and is forbidden. Run elevated:

```powershell
Add-MpPreference -ExclusionPath "<msys2-install-dir>"
Add-MpPreference -ExclusionPath "<wsl-vhdx-dir-found-in-HKCU-Lxss>"
Add-MpPreference -ExclusionPath "<user-dev-directories>"
```

If a third-party antivirus such as Huorong, 360, or Avast is active, Defender
passive mode is CORRECT - do not force-enable it. Add the same exclusions in
that antivirus instead.

## Step 5: Verify - fail loudly

```powershell
where.exe bash            # must print the Step 1 path in a NEW shell
& $gitBash -c "echo ok"   # must print ok
Test-Path "$env:USERPROFILE\.codex\AGENTS.md"
```

Any check failing means STOP and report, do not claim success.

## Step 6: Tell user

- Running processes keep a stale PATH snapshot: the terminal or app that runs
  the agent must be restarted for PATH fixes to take effect.
- Summarize what was changed and point to the Uninstall section below.

---

# Uninstall - full restore to original state

Run these steps in order. The backup file `~/.codex/use-bash-backup.json`
records the original state from Step 0; if it exists, restore from it, and
otherwise fall back to the manual defaults noted in each step.

## U1: Restore AGENTS.md

If the backup shows AGENTS.md existed before, restore the saved copy
`AGENTS.md.use-bash-bak` over the current file. If it did not exist before,
delete `~/.codex/AGENTS.md` - the agent simply falls back to default behavior.

## U2: Restore the WSL bash alias

Rename `bash-wsl.exe` back to `bash.exe` in
`%LOCALAPPDATA%\Microsoft\WindowsApps`, but only if the backup shows the alias
existed originally.

## U3: Restore the user PATH

With a backup, set the User PATH back to the saved `userPath` value verbatim.
Without a backup, remove only the bash directory this skill inserted.

## U4: Restore git config

For each of the seven keys the skill sets, restore the value saved in the
backup, or unset the key if the backup has none. With no backup, unset all
seven keys to return to git defaults.

## U5: Remove Defender exclusions

Remove exactly the paths this skill added, elevated. Never touch exclusions
the user configured themselves.

## U6: Remove the skill itself

- Codex: delete `~/.codex/skills/use-bash/`
- Claude Code / Cursor: follow that tool's skill directory convention

## U7: Delete the backup manifest

Only after every step above succeeded, delete `use-bash-backup.json`.

## U8: Verify and restart

In a NEW shell run `where.exe bash` to confirm restored resolution, and confirm
the skill directory is gone. Remind the user: running processes keep a stale
PATH snapshot, so restart the terminal or agent app to see the restored state.
