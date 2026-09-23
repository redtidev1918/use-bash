#Requires -Version 7.0
<# .SYNOPSIS Make agent use bash on Windows. #>
param(
    [string]$ProxyUrl = "auto",
    [switch]$SkipDefender
)
$ErrorActionPreference = "Stop"
$scriptDir = Split-Path $MyInvocation.MyCommand.Path

Write-Host "=== win-to-unix setup ===" -ForegroundColor Cyan

# 1. Find bash
$bashPath = $null
foreach ($p in @(
    (Get-Command bash -ErrorAction SilentlyContinue).Source,
    "$env:USERPROFILE\scoop\shims\bash.exe",
    "$env:USERPROFILE\scoop\apps\git\current\bin\bash.exe",
    "C:\Program Files\Git\bin\bash.exe"
)) {
    if ($p -and (Test-Path $p)) { $bashPath = $p; break }
}
if (-not $bashPath) {
    Write-Host "Bash not found. Installing git..." -ForegroundColor Yellow
    if (Get-Command scoop -ErrorAction SilentlyContinue) { scoop install git }
    elseif (Get-Command winget -ErrorAction SilentlyContinue) { winget install Git.Git }
    $bashPath = (Get-Command bash -ErrorAction SilentlyContinue).Source
}
if (-not $bashPath) { Write-Host "ERROR: Cannot find or install bash" -ForegroundColor Red; exit 1 }
Write-Host "Bash: $bashPath"

# 2. Detect proxy
if ($ProxyUrl -eq "auto") {
    $ProxyUrl = "none"
    foreach ($port in @(7897, 7890, 1080, 10808)) {
        try {
            $null = Invoke-WebRequest -Uri 'https://www.google.com' -Proxy "http://127.0.0.1:$port" -TimeoutSec 3 -UseBasicParsing -ErrorAction Stop
            $ProxyUrl = "http://127.0.0.1:$port"; break
        } catch { }
    }
}
Write-Host "Proxy: $ProxyUrl"

# 3. Write AGENTS.md
$agentsDir = "$env:USERPROFILE\.codex"
New-Item -ItemType Directory -Force -Path $agentsDir | Out-Null
$agentsPath = "$agentsDir\AGENTS.md"
$templatePath = Join-Path $scriptDir "config\AGENTS.md.template"
if (Test-Path $templatePath) {
    $content = (Get-Content $templatePath -Raw).Replace("{{BASH_PATH}}", $bashPath)
    if (Test-Path $agentsPath) {
        $existing = Get-Content $agentsPath -Raw
        if ($existing -notmatch 'Shell Selection Rules') {
            Add-Content -Path $agentsPath -Value $content -Encoding UTF8
        }
    } else {
        Set-Content -Path $agentsPath -Value $content -Encoding UTF8
    }
    Write-Host "AGENTS.md written"
}

# 4. Git config
git config --global core.autocrlf false
git config --global core.longpaths true
git config --global core.fscache true
git config --global core.preloadindex true
git config --global core.untrackedCache true
git config --global core.fsmonitor true
git config --global gc.auto 0
if ($ProxyUrl -ne "none") {
    git config --global http.proxy $ProxyUrl
    git config --global https.proxy $ProxyUrl
}
Write-Host "Git configured"

# 5. Defender exclusions (optional, admin)
if (-not $SkipDefender) {
    $adminScript = Join-Path $scriptDir "config\optimize-admin.ps1"
    if (Test-Path $adminScript) {
        try {
            Start-Process powershell -Verb RunAs -ArgumentList '-ExecutionPolicy','Bypass','-File',$adminScript -Wait -ErrorAction Stop
            Write-Host "System optimizations applied"
        } catch {
            Write-Host "Skipped system optimizations (need admin)" -ForegroundColor Yellow
        }
    }
}

# 6. Verify
$bashWorks = & $bashPath -c "grep --version" 2>$null
$agentsExists = Test-Path $agentsPath
if ($bashWorks -and $agentsExists) {
    Write-Host "`nDone. Restart terminal." -ForegroundColor Green
    Write-Host "Agent will use bash for grep/sed/awk, PowerShell for Windows tasks." -ForegroundColor Green
} else {
    Write-Host "WARNING: bash=$([bool]$bashWorks) agents=$agentsExists" -ForegroundColor Red
}
