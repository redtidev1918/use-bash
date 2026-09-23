# win-to-unix

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![PowerShell 7+](https://img.shields.io/badge/PowerShell-7.0+-5391FE.svg?logo=powershell&logoColor=white)](https://github.com/PowerShell/PowerShell)
[![Scoop](https://img.shields.io/badge/Install%20with-Scoop-orange?logo=powershell&logoColor=white)](https://scoop.sh)
[![Platform](https://img.shields.io/badge/Platform-Windows%2010%2F11-0078D4.svg?logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![For](https://img.shields.io/badge/Built%20for-Codex%20%2B%20AI%20Agents-8A2BE2.svg)](https://github.com/openai/codex)

一条命令把 Windows 变成能跑 Unix 工具的开发环境。装 MSYS2 bash、Starship、eza、zoxide 和 12 个开发工具，优化 Defender、NTFS、Git 和电源设置，自动写 `AGENTS.md` 让 AI 编程助手用 `grep` 而不是 `Select-String`。

[English](README-en.md)

## 安装

把这句话贴进 Codex、Claude Code、Cursor 或你的编程助手：

```
Install the /win-to-unix skill from https://github.com/redtidev1918/win-to-unix and run the setup
```

或者自己跑：

```powershell
git clone https://github.com/redtidev1918/win-to-unix.git
cd win-to-unix
.\setup.ps1
```

需要 PowerShell 7。装完重启终端。

## 你的 AI 助手获得了什么

安装后自动写 `~/.codex/AGENTS.md`，每个新会话自动遵循：

| 任务 | Shell |
|------|-------|
| `grep`、`sed`、`awk`、`find`、`make`、`tar` | MSYS2 bash（`shell: "bash"`） |
| Windows 路径、.NET、注册表、UE 工具 | PowerShell 7（默认） |
| `apt`、`gcc`、`docker`、完整 Linux | WSL |

助手自动选对的 shell，你不用管。

## 装完后你能用什么

```powershell
grep -rn "UCLASS" src/ --include="*.h"     # 真 grep
find src/ -name "*.cpp" | xargs wc -l      # 真 find + xargs
ll                                          # eza 彩色文件列表 + git 状态
z gun                                       # zoxide 智能跳目录
proxy-off                                   # 关代理
bash                                        # 进 MSYS2 bash
make clean && make                          # Unix 工具链
```

## 装了什么

| 类别 | 内容 |
|------|------|
| 包管理器 | [Scoop](https://scoop.sh) |
| 开发工具 | git、nodejs、python、jq、7zip |
| 终端体验 | [Starship](https://starship.rs) · [eza](https://github.com/eza-community/eza) · [zoxide](https://github.com/ajeetdsouza/zoxide) · ripgrep · fd · fzf · bat |
| Unix 桥接 | [MSYS2](https://www.msys2.org) — bash、grep、sed、awk、find、make、patch、diff、tar、vim |
| 字体 | JetBrainsMono Nerd Font |
| AI 感知 | `~/.codex/AGENTS.md` |

## 性能优化

脚本同时修掉让 Windows 开发变慢的问题：

| 修复项 | 效果 |
|--------|------|
| Defender 排除开发目录 | 文件 I/O 快 3-10 倍 |
| Git `fscache` + `preloadindex` + `untrackedcache` + `fsmonitor` | `git status` 快 2-5 倍 |
| NTFS 最后访问时间戳禁用 | 大量小文件操作变快 |
| 开发者模式 | symlink 免管理员权限 |
| 高性能电源计划 | 编译时 CPU 不降频 |
| WSL2 内存限制 | 防止 WSL 吃光内存 |

## 安装参数

```powershell
.\setup.ps1                                    # 自动检测代理（7897/7890/1080/10808）
.\setup.ps1 -ProxyUrl "http://127.0.0.1:1080"  # 自定义代理
.\setup.ps1 -ProxyUrl "none"                   # 不用代理
.\setup.ps1 -SkipFont                          # 跳过 Nerd Font
.\setup.ps1 -SkipMsys2                         # 跳过 MSYS2
.\setup.ps1 -SkipMirrors                       # 跳过国内镜像
.\setup.ps1 -SkipProfile                       # 跳过 PowerShell Profile
.\setup.ps1 -SkipAgents                        # 跳过 AGENTS.md
```

## 国内用户

默认配置：npm → npmmirror.com，pip → 阿里云镜像，Git 代理，UTF-8（修复 GBK 乱码和 emoji）。不需要就加 `-SkipMirrors`。

## 卸载

```powershell
scoop uninstall git nodejs python starship zoxide eza ripgrep fd fzf bat jq 7zip msys2 JetBrainsMono-NF
Remove-Item ~\.config\starship.toml
# Profile 备份在 setup.ps1 自动创建的 .bak 文件里
```

## 许可证

MIT
