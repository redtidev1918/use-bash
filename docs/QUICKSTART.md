# 快速开始

**语言 / Language:** 中文 · [English](/en/QUICKSTART.md)

## 安装

把下面这句发给 Codex、Claude Code、Cursor 等编码代理：

```text
Install the /use-bash skill from https://github.com/redtidev1918/use-bash and run the setup
```

agent 会自动：克隆仓库 → 安装 skill → 运行 `setup.ps1` → 应用系统优化（一次 UAC 确认）。

也可以手动执行：

```powershell
git clone https://github.com/redtidev1918/use-bash
powershell -ExecutionPolicy Bypass -File .\use-bash\setup.ps1
```

## 设置了什么

1. **skill** 安装到 `~/.codex/skills/use-bash/`
2. **`~/.codex/AGENTS.md`** 写入 shell 规则（幂等：重复运行只更新 Shell Rules 段落，保留你的其他内容）
3. **Git** 全局优化（`autocrlf=false`、`longpaths`、`fsmonitor`、代理）
4. **系统优化**（UAC）：Defender 排除、NTFS、开发者模式、高性能电源、机器级 PATH

## 验证

```powershell
& "C:\Users\12629\scoop\apps\msys2\current\usr\bin\bash.exe" -lc "grep --version"
```

## 遇到问题

- `bash` 卡死 → 大概率解析到了 WSL（`System32\bash.exe`），详见[踩坑记录](Troubleshooting.md)
- AGENTS.md 乱码/重复 → 老版本 setup 的 bug，重跑新版 setup 后手工清理，详见[踩坑记录](Troubleshooting.md)