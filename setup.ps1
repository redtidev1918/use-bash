#Requires -Version 7.0
<#
.SYNOPSIS
    win-to-unix - One-click Unix-like dev shell for Windows + AI agents.
.EXAMPLE
    .\setup.ps1                                    # Default (proxy 7897)
    .\setup.ps1 -ProxyUrl "http://127.0.0.1:1080"  # Custom proxy
    .\setup.ps1 -ProxyUrl "none"                   # No proxy
    .\setup.ps1 -SkipFont -SkipMsys2              # Minimal
#>
param(
    [string]$ProxyUrl = "http://127.0.0.1:7897",
    [switch]$SkipFont,
    [switch]$SkipMsys2,
    [switch]$SkipProfile,
    [switch]$SkipMirrors,
    [switch]$SkipAgents
)
$ErrorActionPreference = "Stop"

# Auto-detect proxy if using default
if ($ProxyUrl -eq "http://127.0.0.1:7897") {
    $detected = $null
    foreach ($port in @(7897, 7890, 1080, 10808)) {
        try {
            $null = Invoke-WebRequest -Uri 'https://www.google.com' -Proxy "http://127.0.0.1:$port" -TimeoutSec 3 -UseBasicParsing -ErrorAction Stop
            $detected = "http://127.0.0.1:$port"
            break
        } catch { }
    }
    if ($detected) {
        Write-Host "Proxy auto-detected: $detected" -ForegroundColor Cyan
        $ProxyUrl = $detected
    } else {
        Write-Host "No proxy detected, using direct connection" -ForegroundColor Yellow
        $ProxyUrl = "none"
    }
}
$script:Step = 0
$script:Total = 8
$scriptDir = Split-Path $MyInvocation.MyCommand.Path

function Write-Step($msg) { $script:Step++; Write-Host "`n[$($script:Step)/$($script:Total)] $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "  [OK] $msg" -ForegroundColor Green }
function Write-Skip($msg) { Write-Host "  [--] $msg" -ForegroundColor DarkGray }

Write-Host "=== win-to-unix Setup ===" -ForegroundColor Magenta

# 1. Scoop
Write-Step "Package Manager (Scoop)"
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression
    $env:Path = [Environment]::GetEnvironmentVariable('Path','User') + ';' + [Environment]::GetEnvironmentVariable('Path','Machine')
    Write-Ok "Scoop installed"
} else { Write-Ok "Scoop already installed" }

# 2. Core Tools
Write-Step "Core Tools (via Scoop)"
$tools = @('git','nodejs','python','starship','zoxide','eza','ripgrep','fd','fzf','bat','jq','7zip')
foreach ($tool in $tools) {
    $installed = (scoop list 2>$null) -match "^$tool\s"
    if ($installed) { Write-Skip "$tool" } else { scoop install $tool 2>$null | Out-Null; Write-Ok $tool }
}

# 3. Nerd Font
Write-Step "Nerd Font (JetBrainsMono)"
if ($SkipFont) { Write-Skip "skipped" }
else {
    if (-not (scoop bucket list 2>$null | Select-String 'nerd-fonts')) { scoop bucket add nerd-fonts 2>$null | Out-Null }
    if (-not (scoop list 2>$null | Select-String 'JetBrainsMono-NF')) { scoop install JetBrainsMono-NF 2>$null | Out-Null }
    Write-Ok "JetBrainsMono Nerd Font"
}

# 4. MSYS2
Write-Step "MSYS2 (Unix toolchain)"
$msys2Path = "$env:USERPROFILE\scoop\apps\msys2\current"
if ($SkipMsys2) { Write-Skip "skipped" }
else {
    if (-not (Test-Path "$msys2Path\usr\bin\bash.exe")) {
        scoop install msys2 2>$null | Out-Null
        & "$msys2Path\usr\bin\bash.exe" --login -c "echo init" 2>$null | Out-Null
    }
    $env:http_proxy = $ProxyUrl; $env:https_proxy = $ProxyUrl
    & "$msys2Path\usr\bin\bash.exe" --login -c "pacman -S --noconfirm --needed base-devel 2>/dev/null" | Out-Null
    Write-Ok "MSYS2 + base-devel"
}

# 5. PowerShell Profile
Write-Step "PowerShell Profile"
$profileDir = "$env:USERPROFILE\Documents\PowerShell"
$profilePath = "$profileDir\Microsoft.PowerShell_profile.ps1"
if ($SkipProfile) { Write-Skip "skipped" }
else {
    if (Test-Path $profilePath) {
        $bak = "$profilePath.bak.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Copy-Item $profilePath $bak
        Write-Ok "Backed up to $(Split-Path $bak -Leaf)"
    }
    New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
    # Use the template file
    $templatePath = Join-Path $scriptDir "config\profile-template.ps1"
    if (Test-Path $templatePath) {
        $content = Get-Content $templatePath -Raw
        $content = $content.Replace('{{PROXY_URL}}', $ProxyUrl)
        Set-Content -Path $profilePath -Value $content -Encoding UTF8
        Write-Ok "Profile generated from template"
    } else {
        Write-Err "Template not found: $templatePath"
    }
}

# 6. Windows Terminal Font
Write-Step "Windows Terminal"
$wtPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path $wtPath) {
    $json = Get-Content $wtPath -Raw | ConvertFrom-Json
    $json.profiles.defaults | Add-Member -Force -NotePropertyName 'font' -NotePropertyValue @{ face = 'JetBrainsMono Nerd Font'; size = 11 }
    $json | ConvertTo-Json -Depth 32 | Set-Content $wtPath -Encoding UTF8
    Write-Ok "Font configured"
} else { Write-Skip "Windows Terminal not found" }

# 7. Configs (Starship + bashrc)
Write-Step "Shell Configs"
$cfgDir = "$env:USERPROFILE\.config"
New-Item -ItemType Directory -Force -Path $cfgDir | Out-Null
$stToml = Join-Path $scriptDir "config\starship.toml"
if (Test-Path $stToml) { Copy-Item $stToml "$cfgDir\starship.toml" -Force; Write-Ok "starship.toml" }
if (-not $SkipMsys2 -and (Test-Path $msys2Path)) {
    $bashrcSrc = Join-Path $scriptDir "config\bashrc.template"
    if (Test-Path $bashrcSrc) {
        $bashrcContent = (Get-Content $bashrcSrc -Raw).Replace('{{PROXY_URL}}', $ProxyUrl)
        $msysHome = "$msys2Path\home\$env:USERNAME"
        New-Item -ItemType Directory -Force -Path $msysHome | Out-Null
        Set-Content -Path "$msysHome\.bashrc" -Value $bashrcContent -Encoding UTF8
        Write-Ok "MSYS2 .bashrc"
    }
}

# 8. Mirrors + AGENTS.md + PATH
Write-Step "Mirrors + AGENTS.md + PATH"
if (-not $SkipMirrors -and (Get-Command npm -ErrorAction SilentlyContinue)) {
    npm config set registry https://registry.npmmirror.com 2>$null; Write-Ok "npm -> npmmirror"
}
if (-not $SkipMirrors -and (Get-Command pip -ErrorAction SilentlyContinue)) {
    $pipDir = "$env:APPDATA\pip"
    New-Item -ItemType Directory -Force -Path $pipDir | Out-Null
    "[global]`nindex-url = https://mirrors.aliyun.com/pypi/simple/`ntrusted-host = mirrors.aliyun.com" | Set-Content "$pipDir\pip.ini" -Encoding UTF8
    Write-Ok "pip -> aliyun"
}
if ($ProxyUrl -ne "none" -and (Get-Command git -ErrorAction SilentlyContinue)) {
    git config --global http.proxy $ProxyUrl; git config --global https.proxy $ProxyUrl
    git config --global core.longpaths true; git config --global core.autocrlf false
    Write-Ok "Git proxy + config"
}
if (-not $SkipAgents) {
    $agentsPath = "$env:USERPROFILE\.codex\AGENTS.md"
    $agentsSrc = Join-Path $scriptDir "config\AGENTS.md.template"
    if (Test-Path $agentsSrc) {
        $agentsContent = (Get-Content $agentsSrc -Raw).Replace('{{PROXY_URL}}', $ProxyUrl)
        New-Item -ItemType Directory -Force -Path (Split-Path $agentsPath) | Out-Null
        if (Test-Path $agentsPath) {
            $existing = Get-Content $agentsPath -Raw
            if ($existing -notmatch 'win-to-unix') { Add-Content $agentsPath $agentsContent -Encoding UTF8; Write-Ok "AGENTS.md appended" }
            else { Write-Skip "AGENTS.md" }
        } else { Set-Content $agentsPath $agentsContent -Encoding UTF8; Write-Ok "AGENTS.md created" }
    }
}
$msysBin = "$env:USERPROFILE\scoop\apps\msys2\current\usr\bin"
if (Test-Path $msysBin) {
    $up = [Environment]::GetEnvironmentVariable('Path','User')
    if ($up -notmatch [regex]::Escape($msysBin)) {
        [Environment]::SetEnvironmentVariable('Path', "$up;$msysBin", 'User')
        Write-Ok "MSYS2 in PATH"
    } else { Write-Skip "MSYS2 PATH" }
}

# ============================================================
# ============================================================
# Performance Optimizations
# ============================================================
Write-Step "Performance (Defender + NTFS + Git + Power)"

# Git performance config
git config --global core.fscache true 2>$null
git config --global core.preloadindex true 2>$null
git config --global core.untrackedCache true 2>$null
git config --global core.fsmonitor true 2>$null
git config --global gc.auto 0 2>$null
git config --global feature.manyFiles true 2>$null
Write-Ok "Git performance config"

# System-level optimizations (need admin)
$adminScript = Join-Path $scriptDir "config\optimize-admin.ps1"
if (Test-Path $adminScript) {
    Start-Process powershell -Verb RunAs -ArgumentList '-ExecutionPolicy', 'Bypass', '-File', $adminScript -Wait
    Write-Ok "Defender + NTFS + DevMode + PowerPlan"
} else {
    Write-Skip "admin script not found"
}

# WSL2 memory limits
$wslPath = "$env:USERPROFILE\.wslconfig"
if (Test-Path $wslPath) {
    $wslContent = Get-Content $wslPath -Raw
    if ($wslContent -notmatch 'memory=') {
        $totalGB = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
        $wslMem = [math]::Max(4, [math]::Floor($totalGB / 2))
        $wslCores = [math]::Max(2, [Environment]::ProcessorCount - 2)
        Add-Content -Path $wslPath -Value "memory=${wslMem}GB"
        Add-Content -Path $wslPath -Value "processors=$wslCores"
        Add-Content -Path $wslPath -Value "swap=2GB"
        Write-Ok "WSL2 memory: ${wslMem}GB"
    } else {
        Write-Skip "WSL2 memory already set"
    }
} else {
    Set-Content -Path $wslPath -Value "[wsl2]`nmemory=8GB`nprocessors=6`nswap=2GB" -Encoding UTF8
    Write-Ok "WSL2 config created"
}

Write-Host "`n=== Setup complete! Restart terminal. ===" -ForegroundColor Green
Write-Host "  ls/ll/lt=eza | z=jump | proxy-on/off | bash=MSYS2" -ForegroundColor Cyan





