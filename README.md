# win-to-unix

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows-0078D4.svg?logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![For](https://img.shields.io/badge/For-Codex%20%2B%20AI%20Agents-8A2BE2.svg)](https://github.com/openai/codex)

告诉 AI 编程助手在 Windows 上用 bash 而不是 PowerShell 来处理文本、文件和搜索任务。

[English](README-en.md)

## 问题

AI 编程助手在 Windows 上默认用 PowerShell。即使是最强的模型，也会不断产出这种代码：

- 需要搜代码 → 写了 3 行 `Get-ChildItem -Recurse | Select-String` 而不是一个 `grep -rn`
- 需要统计行数 → 写了 `Get-Content | Measure-Object -Line` 而不是 `wc -l`
- 需要批量替换 → 写了 `ForEach-Object { $_ -replace }` 而不是 `sed`

这些代码能跑，但更冗长、更难读。模型知道 bash 怎么写——只是默认行为倾向 PowerShell。

## 怎么安装

把这句话贴进 Codex、Claude Code、Cursor 或你的编程助手：

```text
Install the /win-to-unix skill from https://github.com/redtidev1918/win-to-unix and run the setup
```

## 怎么用

装完后你的 agent 自动获得一个新的行为规则集（`AGENTS.md`）。你不需要改任何习惯：

```text
你: "帮我统计项目里有多少行 C++ 代码"

之前 (agent 卡在 PowerShell):
  Get-ChildItem -Recurse -Filter "*.cpp" | Get-Content | Measure-Object -Line

之后 (agent 自动用 bash):
  find src/ -name "*.cpp" -exec cat {} + | wc -l
```

## 它修复了哪些反模式

AGENTS.md 告诉 agent 用 bash 替代这 18 种 PowerShell 写法：

1. **`Select-String`** → 应该用 `grep`
2. **`Get-ChildItem -Recurse -Filter`** → 应该用 `find`
3. **`ForEach-Object { $_ -replace }`** → 应该用 `sed`
4. **`Measure-Object -Line`** → 应该用 `wc -l`
5. **`Group-Object`** → 应该用 `sort | uniq -c`
6. **`Sort-Object -Descending`** → 应该用 `sort -r`
7. **`Where-Object`** → 应该用 `grep -v` 或 `awk`
8. **`Get-Content | Measure-Object`** → 应该用 `wc -l file`
9. **`Copy-Item -Recurse`** → 应该用 `cp -r`
10. **`Remove-Item -Recurse -Force`** → 应该用 `rm -rf`
11. **`New-Item -ItemType Directory`** → 应该用 `mkdir -p`
12. **`Get-Content`** → 应该用 `cat`
13. **`Set-Content`** → 应该用 `echo > file`
14. **`Test-Path`** → 应该用 `test -f`
15. **`Join-Path`** → 应该用 `$dir/$file`
16. **`Get-ChildItem | Where-Object`** → 应该用 `find | grep`
17. **`ForEach-Object { $_.Name }`** → 应该用 `basename`
18. **`ConvertTo-Json`** → 应该用 `jq`

AGENTS.md 还包含一条基本规则：bash 是默认 shell，PowerShell 只用于 Windows 注册表、服务、.NET 对象和 UE 构建工具。

## 仓库结构

- [`skill/SKILL.md`](skill/SKILL.md) — agent 安装手册（检测环境 → 找 bash → 写 AGENTS.md → 验证）
- [`config/AGENTS.md.template`](config/AGENTS.md.template) — agent 行为规则（核心交付物）
- [`config/optimize-admin.ps1`](config/optimize-admin.ps1) — Defender 排除 + NTFS 优化（可选）
- [`setup.ps1`](setup.ps1) — 一键安装脚本

## 许可证

MIT

