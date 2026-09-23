# Codex Win Unix 🪟→🐧

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![PowerShell](https://img.shields.io/badge/PowerShell-7.0+-5391FE.svg)](https://github.com/PowerShell/PowerShell)
[![Scoop](https://img.shields.io/badge/Scoop-compatible-orange.svg)](https://scoop.sh)

> One-click setup for a Unix-like development shell on Windows, optimized for AI coding agents (Codex, Claude, Cursor).

**中文** | [English](#english)

---

## 这是什么

让 Windows 终端获得 macOS/Linux 级别的开发体验，同时让 AI 编程助手（如 Codex）能自然地使用 Unix 命令（`grep`、`sed`、`awk`、`find` 等）。

## 特性

- ⚡ **Scoop 包管理** — 所有开发工具统一管理，一条命令更新
- 🎨 **Starship 提示符** — Rust 编写，<50ms 渲染，显示 Git/语言/耗时
- 📁 **eza + zoxide** — 图标文件列表 + 智能目录跳转
- 🧠 **PSReadLine 预测** — 输入时灰字提示历史命令，↑↓ 搜索
- 🐚 **MSYS2 Bash** — 完整 Unix 工具链（grep/sed/awk/find/make/vim）
- 🔤 **JetBrainsMono Nerd Font** — 完美渲染所有图标
- 🇨🇳 **中国镜像** — npm (npmmirror) / pip (阿里云) 自动配置
- 🌐 **代理集成** — Clash/V2Ray 一键开关
- 🤖 **AGENTS.md** — 告诉 Codex 何时用 bash、何时用 PowerShell

## 快速开始

### 前置要求

- Windows 10 1809+ / Windows 11
- PowerShell 7 ([安装](https://github.com/PowerShell/PowerShell#get-powershell))
- 网络连接（可配置代理）

### 安装

```powershell
# 克隆仓库
git clone https://github.com/redtidev1918/codex-win-unix.git
cd codex-win-unix

# 一键安装（默认代理 http://127.0.0.1:7897）
.\setup.ps1

# 或者不用代理
.\setup.ps1 -ProxyUrl "none"

# 或者自定义代理
.\setup.ps1 -ProxyUrl "http://127.0.0.1:1080"

# 最小安装（跳过字体和 MSYS2）
.\setup.ps1 -SkipFont -SkipMsys2
```

### 重启终端

安装完成后**关闭并重新打开终端**即可。

## 命令速查

| 命令 | 功能 | 替代 |
|------|------|------|
| `ls` / `ll` / `lt` | 彩色文件列表 / 详细 / 树形 | `dir` |
| `z <关键词>` | 智能目录跳转 | `cd` |
| `proxy-on` / `proxy-off` | 开关代理 | — |
| `git-proxy` / `git-noproxy` | 开关 Git 代理 | — |
| `bash` | 进入 MSYS2 Bash | — |
| `gbash` | 进入 Git Bash | — |
| `which <cmd>` | 查看命令路径 | `Get-Command` |
| `mkcd <dir>` | 创建并进入目录 | — |

## 对 AI Agent 的意义

安装后自动生成 `~/.codex/AGENTS.md`，让 Codex 知道：

- **PowerShell 7** → Windows 路径、.NET 对象、UE 工具链
- **MSYS2 Bash** → Unix 管道（`grep | sed | awk`）、Shell 脚本
- **WSL** → 完整 Linux 环境（apt/gcc/docker）

Codex 可以在 `exec_command` 中传 `shell: "bash"` 切换到 Unix Shell，或者直接在 PowerShell 中用 `bash -c "..."` 桥接。

## 作为 Codex Skill 安装

如果你想把这变成一个 Codex 技能：

```bash
# 将 skill 目录复制到 Codex 技能目录
cp -r skill/ ~/.codex/skills/win-unix-shell/
```

然后在 Codex 中说 "帮我设置 Unix shell 环境" 就会触发此技能。

## 自定义

### 修改代理地址

重新运行 `.\setup.ps1 -ProxyUrl "http://your-proxy:port"`

### 添加/移除工具

编辑 `setup.ps1` 中的 `$tools` 数组：

```powershell
$tools = @('git', 'nodejs', 'python', ...)  # 添加你需要的
```

### 修改 Starship 主题

编辑 `config/starship.toml`，参考 [Starship 文档](https://starship.rs/config/)

## 卸载

```powershell
# Scoop 卸载所有工具
scoop uninstall git nodejs python starship zoxide eza ripgrep fd fzf bat jq 7zip msys2 JetBrainsMono-NF

# 删除配置
Remove-Item ~\.config\starship.toml
Remove-Item ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```

## 贡献

欢迎提交 Issue 和 PR！

## License

[MIT](LICENSE)

---

<a name="english"></a>
# English

One-click setup for a Unix-like development shell on Windows, optimized for AI coding agents.

## Features
- Scoop package management for all dev tools
- Starship prompt (Rust, <50ms)
- eza + zoxide for file management
- PSReadLine predictive IntelliSense
- MSYS2 bash with full Unix toolchain
- JetBrainsMono Nerd Font
- China mirrors (npm/pip) + proxy integration
- AGENTS.md for AI agent shell awareness

## Quick Start

```powershell
git clone https://github.com/redtidev1918/codex-win-unix.git
cd codex-win-unix
.\setup.ps1
```

## Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `-ProxyUrl` | Proxy address | `http://127.0.0.1:7897` |
| `-SkipFont` | Skip Nerd Font | — |
| `-SkipMsys2` | Skip MSYS2 | — |
| `-SkipProfile` | Skip PowerShell profile | — |
| `-SkipMirrors` | Skip China mirrors | — |
| `-SkipAgents` | Skip AGENTS.md | — |

## License

MIT
