# Uninstall

use-bash setup backs up the original state to `~/.codex/use-bash-backup.json`
before touching anything, so uninstall restores everything exactly.

## Option 1: let your agent do it

Paste this into Codex, Claude Code, Cursor, or your coding agent:

```text
Uninstall the /use-bash skill completely and restore the original state:
run the Uninstall section (U1-U8) of ~/.codex/skills/use-bash/SKILL.md,
restoring everything from use-bash-backup.json.
```

## Option 2: run the uninstall script

Clone the repo and run in PowerShell from the repo root:

```powershell
.\uninstall.ps1
```

To keep the backup file (for example, to pause instead of remove), add `-KeepBackup`:

```powershell
.\uninstall.ps1 -KeepBackup
```

## What gets restored

| Step | What | Restored to |
|------|------|-------------|
| U1 | `~/.codex/AGENTS.md` | Original file from backup, or deleted if setup created it |
| U2 | WSL bash alias | `bash-wsl.exe` renamed back to `bash.exe` (only if it existed before) |
| U3 | User PATH | Exact value saved by the setup backup |
| U4 | Git config (7 keys) | Original values, or unset back to git defaults |
| U5 | Defender exclusions | Only the paths this skill added; your own exclusions untouched |
| U6 | The skill itself | Deletes `~/.codex/skills/use-bash/` |
| U7 | Backup manifest | Deleted only after all steps succeed |
| U8 | Verify | Run `where.exe bash` in a new shell |

## Notes

- After uninstalling, **restart your terminal or agent app** - running
  processes keep a stale PATH snapshot.
- If a third-party antivirus (Huorong, 360, Avast, ...) is active, Windows
  Defender passive mode is normal; the uninstall script does not and should
  not change that.
- The exact commands for each manual step live in the Uninstall section of
  [`skill/SKILL.md`](https://github.com/redtidev1918/use-bash/blob/main/skill/SKILL.md).
