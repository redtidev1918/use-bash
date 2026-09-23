# use-bash 🐚

**Language / 语言:** [中文](/) · English

Make AI coding agents (Codex / Claude Code / Cursor…) **use bash instead of PowerShell on Windows**.

After setup, your agent gets a behavior rule set (`AGENTS.md`): code search becomes `grep -rn`, line counting becomes `wc -l`, batch replace becomes `sed`. It also tunes Defender, Git, PATH and MSYS2 for speed and reliability.

- [Quick Start](en/QUICKSTART.md)
- [Troubleshooting](../Troubleshooting.md)
- [GitHub repo](https://github.com/redtidev1918/use-bash)

## What it changes

| Scope | Content |
| --- | --- |
| **AGENTS.md** | shell selection rules + 18 PowerShell → bash mappings |
| **Git** | `autocrlf=false`, `longpaths`, `fscache`, `fsmonitor`, proxy |
| **System** (admin) | Defender exclusions for dev dirs, NTFS last-access off, Developer Mode, High Performance power plan |
| **PATH** | bash dir ahead of `System32`/`WindowsApps` so `bash` resolves to the real bash, not WSL |

## Requirements

Windows 10/11 · bash (MSYS2 / Git for Windows / scoop) · PowerShell 5.1+