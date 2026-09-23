# win-to-unix

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows-0078D4.svg?logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![For](https://img.shields.io/badge/For-Codex%20%2B%20AI%20Agents-8A2BE2.svg)](https://github.com/openai/codex)

让你的 AI 编程助手（Codex/Claude/Cursor）在 Windows 上用 `grep`/`sed`/`awk` 而不是卡在 `Select-String`。

## 安装

贴进 Codex：

```
Install the /win-to-unix skill from https://github.com/redtidev1918/win-to-unix and run the setup
```

或者自己跑：

```powershell
git clone https://github.com/redtidev1918/win-to-unix.git
cd win-to-unix
.\setup.ps1
```

## 它做了什么

1. 写 `~/.codex/AGENTS.md`，告诉 agent 永远用 bash 跑 `grep/sed/awk/find`，永远用 PowerShell 只处理 Windows 特有的事
2. 配置 Git（autocrlf、longpaths、性能）
3. 配置代理（自动检测端口）
4. 可选：Defender 排除开发目录（提升文件 I/O）

## 装完后的效果

Agent 遇到"统计所有 .cpp 文件行数"这种任务时：

```
之前（卡在 PowerShell）:
Get-ChildItem -Recurse -Filter "*.cpp" | Get-Content | Measure-Object -Line

之后（自动用 bash）:
find src/ -name "*.cpp" -exec cat {} + | wc -l
```

## 许可证

MIT
