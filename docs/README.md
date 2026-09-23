# use-bash 🐚

**语言 / Language:** 中文 · [English](/en/)

让 AI 编码代理（Codex / Claude Code / Cursor…）在 Windows 上**默认用 bash 而不是 PowerShell**。

安装后，agent 会拿到一套行为规则（`AGENTS.md`）：搜代码变成 `grep -rn`、数行数变成 `wc -l`、批量替换变成 `sed`。同时优化 Defender、Git、PATH 与 MSYS2，让 shell 又快又稳。

- [快速开始](QUICKSTART.md)
- [踩坑记录 / Troubleshooting](Troubleshooting.md)
- [GitHub 仓库](https://github.com/redtidev1918/use-bash)

## 它改了什么

| 范围 | 内容 |
| --- | --- |
| **AGENTS.md** | shell 选择规则 + 18 条 PowerShell → bash 映射 |
| **Git** | `autocrlf=false`、`longpaths`、`fscache`、`fsmonitor`、代理 |
| **系统**（需管理员） | Defender 排除开发目录、NTFS last-access 关闭、开发者模式、高性能电源计划 |
| **PATH** | bash 目录排到 `System32`/`WindowsApps` 之前，`bash` 不再解析到会卡死的 WSL |

## 环境

Windows 10/11 · bash（MSYS2 / Git for Windows / scoop）· PowerShell 5.1+