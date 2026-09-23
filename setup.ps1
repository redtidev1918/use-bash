#Requires -Version 5.1
param([string]$ProxyUrl = "auto", [switch]$SkipDefender)
$ErrorActionPreference = "Stop"
$scriptDir = Split-Path $MyInvocation.MyCommand.Path

Write-Host "=== bash-first setup ===" -ForegroundColor Cyan

# [1/5] Find or install bash
Write-Host "\n[1/5] Finding bash..."
$bashPath = $null; $bashSource = ""
foreach ($c in @(
    @{ p = (Get-Command bash -ErrorAction SilentlyContinue).Source; t = "PATH" },
    @{ p = "$env:USERPROFILE\scoop\shims\bash.exe"; t = "Scoop" },
    @{ p = "C:\Program Files\Git\bin\bash.exe"; t = "Git" },
    @{ p = "C:\Program Files (x86)\Git\bin\bash.exe"; t = "Git x86" }
)) {
    if ($c.p -and (Test-Path $c.p)) { $bashPath = $c.p; $bashSource = $c.t; break }
}
if (-not $bashPath) {
    try { wsl --status 2>$null | Out-Null; if ($LASTEXITCODE -eq 0) { $bashPath = "wsl"; $bashSource = "WSL" } } catch { }
}
if (-not $bashPath) {
    Write-Host "  No bash found. Installing Git for Windows..." -ForegroundColor Yellow
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install Git.Git --accept-source-agreements --accept-package-agreements --silent 2>$null
        $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
        $bashPath = (Get-Command bash -ErrorAction SilentlyContinue).Source
        if (-not $bashPath) { $bashPath = "C:\Program Files\Git\bin\bash.exe" }
        $bashSource = "winget"
    } else {
        Write-Host "  Downloading Git installer..." -ForegroundColor Yellow
        $installer = "$env:TEMP\git-setup.exe"
        Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/latest/download/Git-64-bit.exe" -OutFile $installer -UseBasicParsing
        Start-Process $installer -ArgumentList '/SILENT','/NORESTART' -Wait
        $bashPath = "C:\Program Files\Git\bin\bash.exe"
        $bashSource = "download"
    }
    if (-not (Test-Path $bashPath)) {
        Write-Host "  ERROR: bash not found. Restart terminal and retry." -ForegroundColor Red
        exit 1
    }
}
Write-Host "  Bash: $bashPath ($bashSource)" -ForegroundColor Green

# [2/5] Detect proxy
Write-Host "\n[2/5] Detecting proxy..."
if ($ProxyUrl -eq "auto") {
    $ProxyUrl = "none"
    foreach ($port in @(7897, 7890, 1080, 10808)) {
        try {
            $null = Invoke-WebRequest -Uri 'https://www.google.com' -Proxy "http://127.0.0.1:$port" -TimeoutSec 3 -UseBasicParsing -ErrorAction Stop
            $ProxyUrl = "http://127.0.0.1:$port"; break
        } catch { }
    }
}
Write-Host "  Proxy: $ProxyUrl"

# [3/5] Write AGENTS.md
Write-Host "\n[3/5] Writing AGENTS.md..."
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
            Write-Host "  AGENTS.md appended"
        } else { Write-Host "  AGENTS.md already configured" }
    } else {
        Set-Content -Path $agentsPath -Value $content -Encoding UTF8
        Write-Host "  AGENTS.md created"
    }
}

# [4/5] Git config
Write-Host "\n[4/5] Configuring Git..."
git config --global core.autocrlf false 2>$null
git config --global core.longpaths true 2>$null
git config --global core.fscache true 2>$null
git config --global core.preloadindex true 2>$null
git config --global core.untrackedCache true 2>$null
git config --global core.fsmonitor true 2>$null
git config --global gc.auto 0 2>$null
if ($ProxyUrl -ne "none") {
    git config --global http.proxy $ProxyUrl 2>$null
    git config --global https.proxy $ProxyUrl 2>$null
}
Write-Host "  Git configured"

# [5/5] Defender exclusions (optional, admin)
Write-Host "\n[5/5] System optimizations..."
if (-not $SkipDefender) {
    $adminScript = Join-Path $scriptDir "config\optimize-admin.ps1"
    if (Test-Path $adminScript) {
        try {
            Start-Process powershell -Verb RunAs -ArgumentList '-ExecutionPolicy','Bypass','-File',$adminScript -Wait -ErrorAction Stop
            Write-Host "  Defender + NTFS + Power plan applied"
        } catch { Write-Host "  Skipped (need admin)" -ForegroundColor Yellow }
    }
}

# Verify
$bashWorks = $false
if ($bashSource -eq "WSL") { $bashWorks = (wsl -e bash -c "grep --version" 2>$null) -ne $null }
else { $bashWorks = (& $bashPath -c "grep --version" 2>$null) -ne $null }
$agentsExists = Test-Path $agentsPath

Write-Host "\n=== Result ==="
if ($bashWorks) { Write-Host "  Bash: OK" -ForegroundColor Green } else { Write-Host "  Bash: FAIL" -ForegroundColor Red }
if ($agentsExists) { Write-Host "  AGENTS.md: OK" -ForegroundColor Green } else { Write-Host "  AGENTS.md: FAIL" -ForegroundColor Red }
if ($bashWorks -and $agentsExists) {
    Write-Host "\nDone. Restart terminal." -ForegroundColor Green
} else {
    Write-Host "\nSome checks failed." -ForegroundColor Yellow
}

