# win-to-unix

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![PowerShell 7+](https://img.shields.io/badge/PowerShell-7.0+-5391FE.svg?logo=powershell&logoColor=white)](https://github.com/PowerShell/PowerShell)
[![Scoop](https://img.shields.io/badge/Install%20with-Scoop-orange?logo=powershell&logoColor=white)](https://scoop.sh)
[![Platform](https://img.shields.io/badge/Platform-Windows%2010%2F11-0078D4.svg?logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![For](https://img.shields.io/badge/Built%20for-Codex%20%2B%20AI%20Agents-8A2BE2.svg)](https://github.com/openai/codex)

**One command turns a Windows machine into a Unix-capable dev environment.** Installs MSYS2 bash, Starship, eza, zoxide, and 12 dev tools via Scoop. Optimizes Defender, NTFS, Git, and power settings. Writes `AGENTS.md` so your AI agent uses `grep` instead of `Select-String` — automatically.

## Install

Paste this into Codex, Claude Code, Cursor, or your coding agent:

```
Install the /win-to-unix skill from https://github.com/redtidev1918/win-to-unix and run the setup
```

Or run it yourself:

```powershell
git clone https://github.com/redtidev1918/win-to-unix.git
cd win-to-unix
.\setup.ps1
```

Requires PowerShell 7. Restart your terminal after setup. That's it.

## What your agent gets

After setup, `~/.codex/AGENTS.md` tells your agent:

| Task | Shell |
|------|-------|
| `grep`, `sed`, `awk`, `find`, `make`, `tar` | MSYS2 bash (`shell: "bash"`) |
| Windows paths, .NET, registry, UE tooling | PowerShell 7 (default) |
| `apt`, `gcc`, `docker`, full Linux | WSL |

The agent picks the right shell automatically. You never think about it.

## What you get

```
PS D:\project> grep -rn "UCLASS" src/ --include="*.h"     # real grep
PS D:\project> find src/ -name "*.cpp" | xargs wc -l      # real find + xargs
PS D:\project> ll                                          # eza with icons + git status
PS D:\project> z gun                                       # zoxide smart cd
PS D:\project> proxy-off                                   # toggle proxy
PS D:\project> bash                                        # full MSYS2 bash
bash> make clean && make                                   # Unix toolchain
```

## What gets installed

| Category | Tools |
|----------|-------|
| Package manager | [Scoop](https://scoop.sh) |
| Dev tools | git, nodejs, python, jq, 7zip |
| Terminal UX | [Starship](https://starship.rs) · [eza](https://github.com/eza-community/eza) · [zoxide](https://github.com/ajeetdsouza/zoxide) · ripgrep · fd · fzf · bat |
| Unix bridge | [MSYS2](https://www.msys2.org) — bash, grep, sed, awk, find, make, patch, diff, tar, vim |
| Font | JetBrainsMono Nerd Font |
| AI awareness | `~/.codex/AGENTS.md` |

## Performance optimizations

The script also fixes the things that make Windows slow for development:

| Fix | Impact |
|-----|--------|
| Defender exclusions for dev directories | File I/O 3-10x faster |
| Git `fscache` + `preloadindex` + `untrackedcache` + `fsmonitor` | `git status` 2-5x faster |
| NTFS last-access timestamp disabled | Small file operations faster |
| Developer mode enabled | Symlinks without UAC |
| High Performance power plan | No CPU throttling during builds |
| WSL2 memory limits | Prevents WSL from eating all RAM |

## Setup options

```powershell
.\setup.ps1                                    # Auto-detects proxy (7897/7890/1080/10808)
.\setup.ps1 -ProxyUrl "http://127.0.0.1:1080"  # Custom proxy
.\setup.ps1 -ProxyUrl "none"                   # No proxy
.\setup.ps1 -SkipFont                          # Skip Nerd Font
.\setup.ps1 -SkipMsys2                         # Skip MSYS2
.\setup.ps1 -SkipMirrors                       # Skip China mirrors (npm/pip)
.\setup.ps1 -SkipProfile                       # Skip PowerShell profile
.\setup.ps1 -SkipAgents                        # Skip AGENTS.md
```

## For China

Configured by default: npm → npmmirror.com, pip → aliyun mirror, Git proxy, UTF-8 (fixes GBK). Use `-SkipMirrors` to skip.

## Uninstall

```powershell
scoop uninstall git nodejs python starship zoxide eza ripgrep fd fzf bat jq 7zip msys2 JetBrainsMono-NF
Remove-Item ~\.config\starship.toml
# Restore profile from the .bak file setup.ps1 created
```

## License

MIT
