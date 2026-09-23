# winix

Windows terminal that runs Unix tools natively. One script installs Scoop, MSYS2 bash, Starship, and a PowerShell profile so `grep`, `sed`, `awk`, and `make` work without WSL or a VM.

Built for developers who use AI coding agents (Codex, Claude, Cursor) and are tired of `Get-ChildItem -Recurse | Select-String` when they mean `grep -rn`.

## Two ways to use

**As a Codex skill** (recommended if you use Codex):

```powershell
# Copy the skill into Codex
cp -r skill/ ~/.codex/skills/winix/

# Then just tell Codex:
# "帮我设置 Unix shell 环境" or "set up a better terminal"
```

Codex reads the skill, runs setup, and writes `~/.codex/AGENTS.md`. From then on, every Codex session knows when to use bash vs PowerShell — you never think about it again.

**As a standalone script** (no Codex needed):

```powershell
git clone https://github.com/redtidev1918/winix.git
cd winix
.\setup.ps1
```

## What the agent gets

After setup, `~/.codex/AGENTS.md` tells your AI agent:

| Task | Shell |
|------|-------|
| Windows paths, .NET objects, UE tooling | PowerShell 7 |
| Unix pipelines (`grep \| sed \| awk`) | MSYS2 bash |
| Full Linux (apt, gcc, docker) | WSL |

In `exec_command`, the agent passes `shell: "bash"` to use MSYS2 bash. In PowerShell, `bash -c "cmd"` calls MSYS2 bash. The agent picks the right one automatically.

## Before and after

Finding all `UCLASS` declarations in a UE project:

```bash
# Without winix (PowerShell)
Get-ChildItem -Recurse -Filter "*.h" | Select-String -Pattern "UCLASS" | Group-Object Path | Sort-Object Count -Descending

# With winix (agent uses bash automatically)
grep -rn "UCLASS" Source/ --include="*.h" | cut -d: -f1 | sort | uniq -c | sort -rn
```

## What gets installed

| Category | What |
|----------|------|
| Package manager | [Scoop](https://scoop.sh) |
| Dev tools | git, nodejs, python, jq, 7zip |
| Terminal UX | [Starship](https://starship.rs), [zoxide](https://github.com/ajeetdsouza/zoxide), [eza](https://github.com/eza-community/eza), ripgrep, fd, fzf, bat |
| Unix bridge | [MSYS2](https://www.msys2.org) — bash, grep, sed, awk, find, make, patch, diff, tar, vim |
| Font | JetBrainsMono Nerd Font |

## Setup options

```powershell
.\setup.ps1                                    # Default (proxy 127.0.0.1:7897)
.\setup.ps1 -ProxyUrl "http://127.0.0.1:1080"  # Custom proxy
.\setup.ps1 -ProxyUrl "none"                   # No proxy
.\setup.ps1 -SkipFont                          # Skip Nerd Font
.\setup.ps1 -SkipMsys2                         # Skip MSYS2
.\setup.ps1 -SkipMirrors                       # Skip China mirrors
```

Restart your terminal after setup.

## What you get

```
PS D:\project> ll                              # eza with icons and git status
PS D:\project> grep -rn "TODO" src/ | wc -l    # MSYS2 grep works from PowerShell
PS D:\project> z gun                           # zoxide jumps to GunSurvivors
PS D:\project> proxy-off                       # turn off proxy
PS D:\project> bash                            # enter MSYS2 bash
bash> make clean && make                       # full Unix toolchain
```

## For China

The script configures these by default:

- npm → `registry.npmmirror.com`
- pip → `mirrors.aliyun.com/pypi/simple/`
- Git proxy → your proxy address
- UTF-8 everywhere (fixes GBK garbled text and emoji)

Use `-SkipMirrors` if you don't need this.

## Uninstall

```powershell
scoop uninstall git nodejs python starship zoxide eza ripgrep fd fzf bat jq 7zip msys2 JetBrainsMono-NF
Remove-Item ~\.config\starship.toml
# Restore your profile from the .bak file setup.ps1 created
```

## License

MIT
