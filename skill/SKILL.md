---
name: winix
description: >
  Set up a Unix-like development shell on Windows for AI coding agents.
  Installs Scoop, dev tools, Starship prompt, MSYS2 bash, configures proxy
  and mirrors, and generates AGENTS.md. Use when a Windows user wants a
  better terminal, Unix commands, or complains about PowerShell/encoding.
version: 1.0.0
---

# winix

Turns a Windows terminal into a Unix-capable development environment.

## When to use

- User wants a "better terminal" or "Unix-like shell" on Windows
- User complains about PowerShell encoding (GBK, emoji, garbled Chinese)
- User is setting up a new Windows dev machine
- User wants Codex/Claude to use `grep`/`sed`/`awk` naturally

## Setup

Run from this skill's directory:

```powershell
.\setup.ps1                                    # Default (proxy 127.0.0.1:7897)
.\setup.ps1 -ProxyUrl "http://127.0.0.1:1080"  # Custom proxy
.\setup.ps1 -ProxyUrl "none"                   # No proxy
.\setup.ps1 -SkipFont -SkipMsys2              # Minimal
```

## What gets installed

| Category | Tools |
|----------|-------|
| Package Manager | Scoop |
| Dev Tools | git, nodejs, python, jq, 7zip |
| UX | starship, zoxide, eza, ripgrep, fd, fzf, bat |
| Unix Bridge | msys2 (bash, grep, sed, awk, find, make, patch, diff, tar, vim) |
| Font | JetBrainsMono Nerd Font |

## What gets configured

1. PowerShell 7 profile (UTF-8, PSReadLine, eza aliases, proxy, Unix bridge)
2. Windows Terminal font
3. Starship prompt config
4. MSYS2 .bashrc (proxy, aliases, encoding)
5. npm mirror -> registry.npmmirror.com
6. pip mirror -> mirrors.aliyun.com
7. Git proxy + longpaths + autocrlf
8. ~/.codex/AGENTS.md (shell selection guide)

## After setup

Tell the user to restart their terminal. Commands they get:
- `ls/ll/lt` -> eza with icons
- `z <keyword>` -> smart directory jump (zoxide)
- `proxy-on/off` -> toggle proxy
- `bash` -> enter MSYS2 bash
- `which <cmd>` -> find command path

## Shell guide for agents

| Task | Shell |
|------|-------|
| Windows paths, .NET objects | PowerShell 7 |
| Unix pipelines | MSYS2 bash |
| Full Linux (apt, gcc) | WSL |

In exec_command, pass `shell: "bash"` for MSYS2 bash.
In PowerShell, `bash -c "cmd"` calls MSYS2 bash.
WSL: `wsl -d Ubuntu-24.04 -- cmd`

## Troubleshooting

- **Starship "dumb terminal"**: Normal in pipes/CI. Only affects visual prompt.
- **UTF-8 garbled**: Profile sets UTF-8. If still broken, enable Windows "Beta: Use Unicode UTF-8" in region settings.
- **pacman 404**: Run `pacman -S` without `-y` to skip sync, or set proxy.
- **Scoop not found**: Refresh PATH with `[Environment]::GetEnvironmentVariable('Path','User')`.
