# unix-on-windows

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Windows terminal that runs Unix tools natively. One script, no WSL, no VM.

## Install

Paste this into Codex, Claude Code, Cursor, or your coding agent:

```
Install the /unix-on-windows skill from https://github.com/redtidev1918/unix-on-windows and run the setup
```

Or run it yourself:

```powershell
git clone https://github.com/redtidev1918/unix-on-windows.git
cd unix-on-windows
.\setup.ps1
```

Requires PowerShell 7. Restart your terminal after setup.

## What you get

```
PS D:\project> grep -rn "UCLASS" src/          # real grep
PS D:\project> sed 's/old/new/g' file.txt      # real sed
PS D:\project> ll                              # eza with icons
PS D:\project> z gun                           # smart cd
PS D:\project> bash                            # MSYS2 bash with make/vim/diff
```

Your AI agent automatically uses bash for Unix tasks and PowerShell for Windows tasks after setup. You don't configure anything.

## Options

```powershell
.\setup.ps1 -ProxyUrl "http://127.0.0.1:1080"  # Custom proxy (auto-detects by default)
.\setup.ps1 -ProxyUrl "none"                   # No proxy
.\setup.ps1 -SkipFont                          # Skip Nerd Font
.\setup.ps1 -SkipMsys2                         # Skip MSYS2
.\setup.ps1 -SkipMirrors                       # Skip China mirrors
```

## License

MIT


