# win-to-unix

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows-0078D4.svg?logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![For](https://img.shields.io/badge/For-Codex%20%2B%20AI%20Agents-8A2BE2.svg)](https://github.com/openai/codex)

Tell AI coding agents to use bash instead of PowerShell for text processing, file operations, and code search on Windows.

[中文](README.md)

## Problem

AI coding agents default to PowerShell on Windows. Even the best models keep producing code like:

- To search code → 3 lines of `Get-ChildItem -Recurse | Select-String` instead of one `grep -rn`
- To count lines → `Get-Content | Measure-Object -Line` instead of `wc -l`
- To batch replace → `ForEach-Object { $_ -replace }` instead of `sed`

This code works, but it is more verbose and harder to read. The model already knows bash — it just defaults to PowerShell on Windows.

## How to install

Paste this into Codex, Claude Code, Cursor, or your favorite coding agent:

```text
Install the /win-to-unix skill from https://github.com/redtidev1918/win-to-unix and run the setup
```

## How to use

After setup, your agent gets a new behavior rule set (`AGENTS.md`). You change nothing:

```text
You: "Count the lines of C++ code in my project"

Before (agent stuck on PowerShell):
  Get-ChildItem -Recurse -Filter "*.cpp" | Get-Content | Measure-Object -Line

After (agent uses bash automatically):
  find src/ -name "*.cpp" -exec cat {} + | wc -l
```

## The anti-patterns it fixes

AGENTS.md tells the agent to replace these 18 PowerShell patterns with bash:

1. **`Select-String`** → use `grep`
2. **`Get-ChildItem -Recurse -Filter`** → use `find`
3. **`ForEach-Object { $_ -replace }`** → use `sed`
4. **`Measure-Object -Line`** → use `wc -l`
5. **`Group-Object`** → use `sort | uniq -c`
6. **`Sort-Object -Descending`** → use `sort -r`
7. **`Where-Object`** → use `grep -v` or `awk`
8. **`Get-Content | Measure-Object`** → use `wc -l file`
9. **`Copy-Item -Recurse`** → use `cp -r`
10. **`Remove-Item -Recurse -Force`** → use `rm -rf`
11. **`New-Item -ItemType Directory`** → use `mkdir -p`
12. **`Get-Content`** → use `cat`
13. **`Set-Content`** → use `echo > file`
14. **`Test-Path`** → use `test -f`
15. **`Join-Path`** → use `$dir/$file`
16. **`Get-ChildItem | Where-Object`** → use `find | grep`
17. **`ForEach-Object { $_.Name }`** → use `basename`
18. **`ConvertTo-Json`** → use `jq`

It also teaches the agent the base rule: bash is the default shell, PowerShell is only for Windows registry, services, .NET objects, and UE build tools.

## What's inside

- [`skill/SKILL.md`](skill/SKILL.md) — agent setup instructions (detect → find bash → write AGENTS.md → verify)
- [`config/AGENTS.md.template`](config/AGENTS.md.template) — agent behavior rules (the core deliverable)
- [`config/optimize-admin.ps1`](config/optimize-admin.ps1) — Defender exclusions + NTFS optimization (optional)
- [`setup.ps1`](setup.ps1) — one-click setup script

## License

MIT

