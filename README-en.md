# win-to-unix

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows-0078D4.svg?logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![For](https://img.shields.io/badge/For-Codex%20%2B%20AI%20Agents-8A2BE2.svg)](https://github.com/openai/codex)

Make your AI coding agent use `grep`/`sed`/`awk` on Windows instead of getting stuck on `Select-String`.

[中文](README.md)

## Install

Paste into Codex:

```
Install the /win-to-unix skill from https://github.com/redtidev1918/win-to-unix and run the setup
```

Or run it yourself:

```powershell
git clone https://github.com/redtidev1918/win-to-unix.git
cd win-to-unix
.\setup.ps1
```

## What it does

1. Writes `~/.codex/AGENTS.md` telling the agent to always use bash for `grep/sed/awk/find` and PowerShell only for Windows-specific tasks
2. Configures Git (autocrlf, longpaths, performance)
3. Configures proxy (auto-detects port)
4. Optional: Defender exclusions for dev directories

## Before / After

When the agent needs to "count lines in all .cpp files":

```
Before (stuck on PowerShell):
Get-ChildItem -Recurse -Filter "*.cpp" | Get-Content | Measure-Object -Line

After (agent picks bash automatically):
find src/ -name "*.cpp" -exec cat {} + | wc -l
```

## License

MIT
