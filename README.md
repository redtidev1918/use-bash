# winix

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Windows terminal that runs Unix tools natively. One script installs Scoop, MSYS2 bash, Starship, and a PowerShell profile so `grep`, `sed`, `awk`, and `make` work without WSL or a VM.

## How to install winix

The easiest way is to paste this into Codex, Claude Code, Cursor, or your favorite coding agent:

```
Install the /winix skill from https://github.com/redtidev1918/winix and run the setup
```

Or install it yourself:

```powershell
git clone https://github.com/redtidev1918/winix.git
cd winix
.\setup.ps1
```

Requires PowerShell 7. Restart your terminal after setup.

## How to use winix

### Daily commands you get

```powershell
ls                              # eza with icons, colored
ll                              # eza with details, git status, permissions
lt                              # eza tree view
z gun                           # zoxide jumps to any dir matching "gun"
grep -rn "UCLASS" src/          # real grep, not PowerShell Select-String
sed 's/old/new/g' file.txt     # real sed
awk '{print $2}' data.csv      # real awk
make                            # real make
proxy-on / proxy-off           # toggle proxy (default 127.0.0.1:7897)
which git                       # find command path
bash                            # enter MSYS2 bash
```

### What your AI agent gets

After setup, winix writes `~/.codex/AGENTS.md`. From then on, every Codex session knows:

| Task | Shell |
|------|-------|
| Windows paths, .NET objects, UE tooling | PowerShell 7 |
| Unix pipelines (`grep \| sed \| awk`) | MSYS2 bash |
| Full Linux (apt, gcc, docker) | WSL |

So when you ask Codex "count the lines in all .cpp files", it runs `find ... \| wc -l` in bash instead of `Get-ChildItem ... \| Measure-Object -Line` in PowerShell. You don't configure anything.

### Setup options

```powershell
.\setup.ps1                                    # Default (proxy 127.0.0.1:7897)
.\setup.ps1 -ProxyUrl "http://127.0.0.1:1080"  # Custom proxy
.\setup.ps1 -ProxyUrl "none"                   # No proxy
.\setup.ps1 -SkipFont                          # Skip Nerd Font
.\setup.ps1 -SkipMsys2                         # Skip MSYS2
.\setup.ps1 -SkipMirrors                       # Skip China mirrors (npm/pip)
```

## What it installs

| Category | What |
|----------|------|
| Package manager | [Scoop](https://scoop.sh) |
| Dev tools | git, nodejs, python, jq, 7zip |
| Terminal UX | [Starship](https://starship.rs), [zoxide](https://github.com/ajeetdsouza/zoxide), [eza](https://github.com/eza-community/eza), ripgrep, fd, fzf, bat |
| Unix bridge | [MSYS2](https://www.msys2.org) — bash, grep, sed, awk, find, make, patch, diff, tar, vim |
| Font | JetBrainsMono Nerd Font |
| AI awareness | `~/.codex/AGENTS.md` |

## For China

Configured by default: npm → npmmirror.com, pip → aliyun mirror, Git proxy, UTF-8 (fixes GBK garbled text). Use `-SkipMirrors` to skip.

## Uninstall

```powershell
scoop uninstall git nodejs python starship zoxide eza ripgrep fd fzf bat jq 7zip msys2 JetBrainsMono-NF
Remove-Item ~\.config\starship.toml
```

## License

MIT
