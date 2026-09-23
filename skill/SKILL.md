---
name: win-unix-shell
description: >
  Set up a Unix-like development shell environment on Windows for AI coding agents
  (Codex/Claude/Cursor). Installs Scoop, dev tools, Starship prompt, MSYS2 bash,
  configures proxies and mirrors, and generates AGENTS.md so the agent knows how
  to use Unix tools. Designed for Chinese developers who need proxy/mirror support.
version: 1.0.0
---

# Win Unix Shell Setup

You are helping a Windows user set up a Unix-like development shell environment
optimized for AI coding agents.

## When to use this skill
- User wants a "better terminal" or "Unix-like shell" on Windows
- User complains about PowerShell experience or encoding issues (GBK, emoji)
- User is setting up a new Windows dev machine
- User wants Codex to use Unix commands (grep/sed/awk) naturally

## Quick Setup

Run the setup script from this skill's directory:

```powershell
.\setup.ps1                                    # Default (proxy 7897)
.\setup.ps1 -ProxyUrl "http://127.0.0.1:1080"  # Custom proxy
.\setup.ps1 -ProxyUrl "none"                   # No proxy
.\setup.ps1 -SkipFont -SkipMsys2              # Minimal setup
```

## What it installs

| Category | Tools |
|----------|-------|
| Package Manager | Scoop |
| Dev Tools | git, nodejs, python, jq, 7zip |
| UX | starship, zoxide, eza, ripgrep, fd, fzf, bat |
| Unix Bridge | msys2 (bash, grep, sed, awk, find, make, patch, diff, tar, vim) |
| Font | JetBrainsMono Nerd Font |

## What it configures

1. PowerShell 7 profile (UTF-8, PSReadLine, aliases, proxy, Unix bridge)
2. Windows Terminal font (JetBrainsMono Nerd Font)
3. Starship prompt config
4. MSYS2 .bashrc (proxy, aliases, encoding)
5. npm mirror -> registry.npmmirror.com
6. pip mirror -> mirrors.aliyun.com
7. Git proxy + longpaths + autocrlf
8. AGENTS.md -> tells Codex how to use bash/PowerShell/WSL

## After setup

Tell the user to restart their terminal. Key commands:
- `ls/ll/lt` -> eza with icons
- `z <keyword>` -> smart directory jump
- `proxy-on/off` -> toggle proxy
- `bash` -> enter MSYS2 bash
- `which <cmd>` -> find command location

## Shell selection guide for agents

| Task | Shell |
|------|-------|
| Windows paths, .NET objects | PowerShell 7 |
| Unix pipelines (grep/sed/awk) | MSYS2 bash |
| Full Linux (apt, gcc, docker) | WSL |

In exec_command, pass `shell: "bash"` for MSYS2 bash.
In PowerShell, `bash -c "cmd"` calls MSYS2 bash.
WSL: `wsl -d Ubuntu-24.04 -- cmd`

## Troubleshooting

- **Starship shows "dumb terminal"**: Normal in non-interactive mode (pipes/CI). Only affects visual prompt.
- **UTF-8 issues**: The profile sets `[Console]::OutputEncoding = UTF8`. If issues persist, check Windows "Beta: Use Unicode UTF-8 for worldwide language support" setting.
- **MSYS2 pacman 404 errors**: Use `pacman -S` (without `-y`) to skip database sync, or configure proxy.
- **Scoop not found after install**: Refresh PATH: `$env:Path = [Environment]::GetEnvironmentVariable('Path','User') + ';' + [Environment]::GetEnvironmentVariable('Path','Machine')`
