# 卸载 / Uninstall

use-bash 的 setup 在修改任何配置之前，都会先把原始状态备份到 `~/.codex/use-bash-backup.json`。卸载时按备份精确还原，不留残留。

## 方式一：让 agent 帮你卸载

把这句话贴进 Codex、Claude Code、Cursor 或你的编程助手：

```text
Uninstall the /use-bash skill completely and restore the original state:
run the Uninstall section (U1-U8) of ~/.codex/skills/use-bash/SKILL.md,
restoring everything from use-bash-backup.json.
```

## 方式二：运行卸载脚本

克隆仓库后，在仓库目录以 PowerShell 运行：

```powershell
.\uninstall.ps1
```

想保留备份文件（比如只想暂时停用），加 `-KeepBackup`：

```powershell
.\uninstall.ps1 -KeepBackup
```

## 卸载内容一览

| 步骤 | 还原对象 | 还原方式 |
|------|----------|----------|
| U1 | `~/.codex/AGENTS.md` | 从备份还原原文件；setup 之前不存在则直接删除 |
| U2 | WSL bash 别名 | `bash-wsl.exe` 改回 `bash.exe`（仅当原来存在） |
| U3 | 用户 PATH | 恢复为备份中保存的原值 |
| U4 | git 配置（7 项） | 恢复原值；原来没有的键则 unset 回 git 默认 |
| U5 | Defender 排除项 | 只删除本 skill 添加的路径，不动用户自己的配置 |
| U6 | skill 本体 | 删除 `~/.codex/skills/use-bash/` |
| U7 | 备份清单 | 全部成功后才删除 |
| U8 | 验证 | 新终端运行 `where.exe bash` 确认解析已还原 |

## 注意事项

- 卸载完成后**重启终端或 agent 应用**：运行中的进程持有旧的 PATH 快照，不重启看不到还原效果。
- 第三方杀软（如火绒、360）在运行时，Windows Defender 处于被动模式是正常现象，卸载脚本不会、也不需要去改动它。
- 手动执行每一步的具体命令见 [`skill/SKILL.md`](https://github.com/redtidev1918/use-bash/blob/main/skill/SKILL.md) 的 Uninstall 章节。
