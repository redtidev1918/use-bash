---
title: use-bash
---

# use-bash

**Tell AI coding agents to use bash instead of PowerShell on Windows.**

After setup, your agent gets a behavior rule set (`AGENTS.md`): code search becomes `grep -rn`, line counting becomes `wc -l`, batch replace becomes `sed`. Also tunes Defender, Git, PATH and MSYS2 for speed.

## Install

Paste this into Codex, Claude Code, Cursor, or your favorite coding agent:

```text
Install the /use-bash skill from https://github.com/redtidev1918/use-bash and run the setup
```

The agent will clone the repo, install the skill, run `setup.ps1`, and apply system optimizations (one UAC prompt).

## What it changes

- **AGENTS.md** — shell selection rules + 18 PowerShell → bash mappings
- **Git** — `autocrlf=false`, `longpaths`, `fscache`, `fsmonitor`, proxy
- **System** (admin) — Defender exclusions for dev dirs, NTFS last-access off, Developer Mode, High Performance power plan
- **PATH** — bash dir moved ahead of `System32`/`WindowsApps` so `bash` resolves to the real bash, not WSL

## Docs

- [踩坑记录 / Troubleshooting](Troubleshooting) — every issue hit in a real install, with root causes and fixes
- [README (English)](https://github.com/redtidev1918/use-bash#readme) · [README (中文)](https://github.com/redtidev1918/use-bash/blob/main/README.md)

## Requirements

Windows 10/11 · bash (MSYS2 / Git for Windows / scoop) · PowerShell 5.1+