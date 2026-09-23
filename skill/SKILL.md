---
name: win-to-unix
description: >
  Turn Windows into a Unix-capable dev environment for AI coding agents.
  Installs Scoop, MSYS2 bash, Starship, dev tools. Optimizes Defender, NTFS,
  Git, and power settings for speed. Writes AGENTS.md so the agent uses
  grep/sed/awk naturally. Use when a Windows user wants a better terminal,
  Unix commands, faster file I/O, or has encoding issues (GBK, emoji).
---

# win-to-unix

Turn a Windows machine into a Unix-capable dev environment. Follow these steps in order.

## Step 1: Detect

```powershell
# Check what's already installed
$hasPwsh = [bool](Get-Command pwsh -ErrorAction SilentlyContinue)
$hasScoop = [bool](Get-Command scoop -ErrorAction SilentlyContinue)
$hasStarship = [bool](Get-Command starship -ErrorAction SilentlyContinue)

# Detect proxy (test common ports)
$proxyPort = $null
foreach ($port in @(7897, 7890, 1080, 10808)) {
    try {
        $null = Invoke-WebRequest -Uri 'https://www.google.com' -Proxy "http://127.0.0.1:$port" -TimeoutSec 3 -UseBasicParsing -ErrorAction Stop
        $proxyPort = $port; break
    } catch { }
}
```

Decisions:
- No pwsh → `winget install Microsoft.PowerShell` first
- No scoop → setup.ps1 handles it
- Proxy found → pass port to setup.ps1
- No proxy → pass `-ProxyUrl "none"`
- Starship exists → ask user before overwriting profile

## Step 2: Clone and run

```powershell
git clone https://github.com/redtidev1918/win-to-unix.git "$env:USERPROFILE\.win-to-unix"
cd "$env:USERPROFILE\.win-to-unix"
.\setup.ps1   # or .\setup.ps1 -ProxyUrl "http://127.0.0.1:$proxyPort" or -ProxyUrl "none"
```

## Step 3: Handle errors

| Problem | Fix |
|---------|-----|
| `scoop: command not found` | `$env:Path = [Environment]::GetEnvironmentVariable('Path','User') + ';' + [Environment]::GetEnvironmentVariable('Path','Machine')` |
| `scoop install` silent fail | Run `scoop install <name>` individually to see error |
| pacman 404 | Use `pacman -S` without `-y` |
| Font missing after install | Restart Windows Terminal |
| Script execution blocked | `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force` |
| Admin prompt denied | Setup continues without Defender/NTFS/Power optimizations. Tell user to run `config\optimize-admin.ps1` manually as admin. |

## Step 4: Verify

```powershell
# All should resolve
Get-Command git, node, python, starship, zoxide, eza, rg, fd, jq, bat, 7z

# Bash should work
& "$env:USERPROFILE\scoop\apps\msys2\current\usr\bin\bash.exe" --login -c "grep --version | head -1"

# AGENTS.md exists
Test-Path "$env:USERPROFILE\.codex\AGENTS.md"
```

All pass → tell user to restart terminal. Any fail → troubleshoot before reporting success.

## Step 5: Report to user

```
Setup complete. Restart your terminal (close and reopen).

Installed: Scoop + 12 dev tools + MSYS2 bash + Starship + Nerd Font
Optimized: Defender exclusions + NTFS + Git performance + High Performance power plan
Configured: UTF-8, proxy, npm/pip mirrors, AGENTS.md for AI shell selection

Your agent now automatically uses bash for grep/sed/awk and PowerShell for Windows tasks.
```

## Step 6: Future session rules

After setup, AGENTS.md is written. Every new session must follow these rules:

1. Use `shell: "bash"` in exec_command for: grep, sed, awk, find, xargs, make, patch, diff, tar, curl, vim
2. Use default PowerShell 7 for: Windows paths, .NET objects, registry, services, UE tooling
3. Use `wsl -d Ubuntu-24.04 -- cmd` for: apt, gcc, docker, full Linux
4. NEVER use `Select-String` when `grep` is available
5. NEVER use `Get-ChildItem -Filter` when `find` is available
6. NEVER use `ForEach-Object { $_ -replace }` when `sed` is available
7. For pipelines with 2+ stages, always use bash
