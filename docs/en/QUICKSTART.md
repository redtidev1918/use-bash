# Quick Start

**Language / 语言:** [中文](/QUICKSTART.md) · English

## Install

Paste this into Codex, Claude Code, Cursor, or your favorite coding agent:

```text
Install the /use-bash skill from https://github.com/redtidev1918/use-bash and run the setup
```

The agent will clone the repo, install the skill, run `setup.ps1`, and apply system optimizations (one UAC prompt).

Or run it manually:

```powershell
git clone https://github.com/redtidev1918/use-bash
powershell -ExecutionPolicy Bypass -File .\use-bash\setup.ps1
```

## What gets set up

1. **Skill** installed to `~/.codex/skills/use-bash/`
2. **`~/.codex/AGENTS.md`** shell rules (idempotent: re-runs only refresh the Shell Rules section and keep your own content)
3. **Git** global tuning (`autocrlf=false`, `longpaths`, `fsmonitor`, proxy)
4. **System optimizations** (UAC): Defender exclusions, NTFS, Developer Mode, High Performance power plan, machine-level PATH

## Verify

```powershell
& "C:\Users\12629\scoop\apps\msys2\current\usr\bin\bash.exe" -lc "grep --version"
```

## Troubleshooting

- `bash` hangs → it likely resolved to WSL (`System32\bash.exe`); see [Troubleshooting](../Troubleshooting.md)
- AGENTS.md mojibake/duplication → old setup bug; re-run the fixed setup and clean up manually, see [Troubleshooting](../Troubleshooting.md)