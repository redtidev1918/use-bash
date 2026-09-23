# Troubleshooting / 踩坑记录

Real-world issues found while installing and running `use-bash` on a Windows 11 machine (scoop MSYS2 + WSL Ubuntu-24.04 + Windows PowerShell 5.1 / PowerShell 7). English TL;DR at the bottom.

## 1. AGENTS.md 写入后乱码 + 内容重复

**现象**：setup 运行后 `~/.codex/AGENTS.md` 里模板的 `—`、`→` 变成 `鈥?`、`鈫?`，且表格内容重复。

**根因**：
1. Windows PowerShell 5.1 的 `Get-Content -Raw` 不带 `-Encoding UTF8` 时，把**无 BOM 的 UTF-8 文件按 ANSI 读**，中文标点/破折号全部乱码。
2. 用 `-replace "(?s)# Shell Rules.*", $content` 更新时，`$content` 作为**正则替换串**被二次解析：模板里的 `` `$dir/$file `` 等 `$` 序列被当成捕获组引用吃掉。

**修复**：
- 读写统一用 `[System.IO.File]::ReadAllText/WriteAllText` + 显式 `UTF8Encoding($false)`（无 BOM）。
- 放弃正则替换，改用字面量 `# Shell Rules` 标记做 `IndexOf` + `Substring` 拼接：前导内容原样保留，段落整体重建。

## 2. setup 自检报 "Bash: FAIL"（误报）

**现象**：bash 明明能用，setup 最后一项检查失败。

**根因**：自检用 `bash -c "grep --version"`，**非登录 shell 不会加载 `/etc/profile`，`/usr/bin` 不在 PATH 上**，于是 `grep` 找不到。

**修复**：改用 `-lc`（login shell）。或非登录场景手动 `export PATH=/usr/bin:/bin;`。

## 3. `shell: "bash"` / `bash -c` 无输出卡死（最大坑）

**现象**：AI agent（Codex 等）里用 `shell: "bash"` 执行任何命令都挂起，连 `echo` 都不返回。

**排查**：
- `.bashrc` 的 `proxy_on` **是清白的**——它只 export 变量加一行 echo，登录 shell 下瞬间完成。
- `Get-Command bash` 解析到 `C:\WINDOWS\system32\bash.exe` —— 这是 **WSL 的 bash**，在 stdio 被管道接管时（agent 的典型场景）即使 `echo ok` 也挂死。
- `wsl.exe -d Ubuntu-24.04 -e bash -c echo` 同样挂死，且 `wsl --shutdown` 后复测仍挂 —— WSL 服务层本身有问题。

**根因**：**机器级（Machine）PATH 永远排在用户级（User）PATH 之前**。`System32` 在机器级 PATH 里，所以无论用户级 PATH 怎么把 MSYS2 提前，裸的 `bash` 永远先命中 System32 的 WSL bash。setup 原来只修用户级 PATH，治标不治本。

**修复**：在 `optimize-admin.ps1`（已提权）里把 bash 目录前置到**机器级 PATH** 最前面：
```powershell
[Environment]::SetEnvironmentVariable("Path", "$msysDir;" + $mp, "Machine")
```
修复后重启终端/Codex，`shell: "bash"` 直接命中 MSYS2。

**过渡方案**（机器级 PATH 未修时）：agent 里改用全路径 `& "C:\...\msys2\current\usr\bin\bash.exe" -lc "cmd"`。

## 4. PATH 相关的两个次要坑

- Scoop 的 shim 目录在用户级 PATH，同样排在 System32 之后，救不了 `bash` 解析。
- 排查 PATH 时注意：`Start-Process -UseNewEnvironment` 拿到的是"机器 PATH + 用户 PATH"的合成结果，而不是当前进程的旧环境，适合验证 PATH 修复是否真正生效。

## 5. 提权（UAC）自动化的注意事项

- `Start-Process -Verb RunAs` 被用户取消时**不抛异常给调用方**（除非加 try/catch），调用脚本要自己检测副作用（例如让提权进程写一个结果文件再检查）。
- 传复杂命令给提权进程时，用 `-EncodedCommand`（Base64 UTF-16LE）最稳，避免多层引号转义。
- 弹 UAC 前先告诉用户"请点是"，连续静默弹窗只会被忽略/拒绝。

## 6. PowerShell 5.1 vs 7 差异（写脚本时踩过）

| 差异点 | 5.1 | 7 |
|---|---|---|
| `Get-Content` 默认编码 | ANSI（无 BOM 的 UTF-8 会乱码） | UTF-8 |
| `Set-Content -Encoding UTF8` | 带 BOM | 不带 BOM |
| `Get-Content -Encoding Byte` | 可用 | 已移除，改 `-AsByteStream` |

结论：**跨版本脚本一律用 `[System.IO.File]` + 显式 Encoding，不要依赖默认值**。

## 7. MSYS2 性能/体验优化清单（已应用）

- `.bashrc`：`HISTSIZE=10000`、`HISTCONTROL=ignoreboth:erasedups`、`histappend`、`checkwinsize`
- `MAKEFLAGS="-j$(nproc)"`：并行 make 默认打开（UE/dev 构建提速）
- `/etc/pacman.conf`：`ParallelDownloads = 5`
- Defender 排除 scoop/MSYS2 目录（`optimize-admin.ps1`）
- 登录 shell 启动实测约 270ms

## 8. Windows 下 bash 选型结论

| 方案 | 结论 |
|---|---|
| **MSYS2** | ✅ 首选。工具链完整、pacman 可扩展、NTFS 原生性能好 |
| Git for Windows bash | 备选，本质精简版 MSYS2，已有 MSYS2 就没必要 |
| WSL | 仅适合纯 Linux 场景（apt/Docker/systemd）；跨 `/mnt/c` I/O 慢，且本机实测服务层挂死 |

---

## English TL;DR

1. **AGENTS.md mojibake + duplication** — PS 5.1 reads BOM-less UTF-8 as ANSI; regex replacement ate `$`-sequences. Fix: `[System.IO.File]` + explicit UTF-8, literal marker split instead of regex.
2. **"Bash: FAIL" false negative** — non-login `bash -c` lacks `/usr/bin` on PATH. Fix: `-lc`.
3. **`shell: "bash"` hangs** — resolves to `System32\bash.exe` (WSL), which hangs on piped stdio; Machine PATH always precedes User PATH so user-level fixes never win. Fix: prepend bash dir to Machine PATH (in elevated `optimize-admin.ps1`).
4. **UAC automation** — declined `RunAs` throws only in the caller if unhandled otherwise; detect side effects, prefer `-EncodedCommand`.
5. **PS 5.1 vs 7** — never rely on default encodings; use explicit `[System.IO.File]` APIs.
6. **Bash choice** — MSYS2 first, Git Bash unnecessary, WSL for pure-Linux only.