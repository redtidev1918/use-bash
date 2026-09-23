#Requires -Version 5.1
param([string]$ProxyUrl = "auto", [switch]$SkipDefender)
$ErrorActionPreference = "Stop"
$scriptDir = Split-Path $MyInvocation.MyCommand.Path
Write-Host "=== use-bash setup ===" -ForegroundColor Cyan
Write-Host "[1/6] Finding bash..."
$bashPath = $null; $bashSource = ""; $bashDir = $null
foreach ($c in @(
  @{ p = "$env:USERPROFILE\scoop\apps\msys2\current\usr\bin\bash.exe"; t = "MSYS2"; d = "$env:USERPROFILE\scoop\apps\msys2\current\usr\bin" },
  @{ p = "$env:USERPROFILE\scoop\shims\bash.exe"; t = "Scoop"; d = "$env:USERPROFILE\scoop\shims" },
  @{ p = "C:\Program Files\Git\bin\bash.exe"; t = "Git"; d = "C:\Program Files\Git\bin" }
)) { if (Test-Path $c.p) { $bashPath = $c.p; $bashSource = $c.t; $bashDir = $c.d; break } }
$pathBash = (Get-Command bash -ErrorAction SilentlyContinue).Source
if (-not $bashPath -and $pathBash -and $pathBash -notmatch "WindowsApps") { $bashPath = $pathBash; $bashSource = "PATH"; $bashDir = Split-Path $pathBash }
if (-not $bashPath) { Write-Host "  No bash found. Install Git for Windows manually." -ForegroundColor Red; exit 1 }
Write-Host "[2/6] Fixing PATH order..."
$windowsApps = "$env:USERPROFILE\AppData\Local\Microsoft\WindowsApps"
if ($bashDir -and (Test-Path $windowsApps)) {
  $userPath = [Environment]::GetEnvironmentVariable("Path","User")
  $pathParts = $userPath -split ";" | Where-Object { $_ }
  $bashIdx = [array]::IndexOf($pathParts, $bashDir); $waIdx = [array]::IndexOf($pathParts, $windowsApps)
  if ($bashIdx -ge 0 -and $waIdx -ge 0 -and $bashIdx -gt $waIdx) {
    $pathParts = @($pathParts[$bashIdx]) + @($pathParts | Where-Object { $_ -ne $bashDir })
    [Environment]::SetEnvironmentVariable("Path", ($pathParts -join ";"), "User")
    Write-Host "  PATH fixed: bash dir moved before WindowsApps (restart terminal)" -ForegroundColor Yellow
  } elseif ($bashIdx -lt 0) { [Environment]::SetEnvironmentVariable("Path", "$bashDir;$userPath","User"); Write-Host "  PATH fixed: bash dir prepended" -ForegroundColor Yellow }
  else { Write-Host "  PATH order OK" }
}
Write-Host "  Bash: $bashPath ($bashSource)" -ForegroundColor Green
Write-Host "[3/6] Detecting proxy..."
if ($ProxyUrl -eq "auto") { $ProxyUrl = "none"; foreach ($port in @(7897,7890,1080,10808)) { try { $null = Invoke-WebRequest -Uri "https://www.google.com" -Proxy "http://127.0.0.1:$port" -TimeoutSec 3 -UseBasicParsing -ErrorAction Stop; $ProxyUrl = "http://127.0.0.1:$port"; break } catch {} } }
Write-Host "  Proxy: $ProxyUrl"
Write-Host "[4/6] Writing AGENTS.md..."
$agentsDir = "$env:USERPROFILE\.codex"; New-Item -ItemType Directory -Force -Path $agentsDir | Out-Null
$agentsPath = "$agentsDir\AGENTS.md"
$templatePath = Join-Path $scriptDir "config\AGENTS.md.template"
if (Test-Path $templatePath) {
  $utf8 = New-Object System.Text.UTF8Encoding($false)
  $content = [System.IO.File]::ReadAllText($templatePath, [System.Text.Encoding]::UTF8).Replace("{{BASH_PATH}}", $bashPath)
  if (Test-Path $agentsPath) {
    $existing = [System.IO.File]::ReadAllText($agentsPath, [System.Text.Encoding]::UTF8)
    $marker = "# Shell Rules"
    $idx = $existing.IndexOf($marker, [System.StringComparison]::Ordinal)
    if ($idx -ge 0) {
      $newContent = $existing.Substring(0, $idx).TrimEnd() + "`r`n`r`n" + $content.TrimEnd() + "`r`n"
      [System.IO.File]::WriteAllText($agentsPath, $newContent, $utf8)
      Write-Host "  AGENTS.md updated"
    } else {
      [System.IO.File]::WriteAllText($agentsPath, $existing.TrimEnd() + "`r`n`r`n" + $content.TrimEnd() + "`r`n", $utf8)
      Write-Host "  AGENTS.md appended"
    }
  } else {
    [System.IO.File]::WriteAllText($agentsPath, $content.TrimEnd() + "`r`n", $utf8)
    Write-Host "  AGENTS.md created"
  }
}
Write-Host "[5/6] Configuring Git..."
git config --global core.autocrlf false 2>$null
git config --global core.longpaths true 2>$null
git config --global core.fscache true 2>$null
git config --global core.preloadindex true 2>$null
git config --global core.untrackedCache true 2>$null
git config --global core.fsmonitor true 2>$null
git config --global gc.auto 0 2>$null
if ($ProxyUrl -ne "none") { git config --global http.proxy $ProxyUrl 2>$null; git config --global https.proxy $ProxyUrl 2>$null }
Write-Host "  Git configured"
Write-Host "[6/6] System optimizations..."
if (-not $SkipDefender) { $adminScript = Join-Path $scriptDir "config\optimize-admin.ps1"; if (Test-Path $adminScript) { try { Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy","Bypass","-File",$adminScript -Wait -ErrorAction Stop; Write-Host "  Applied" } catch { Write-Host "  Skipped (need admin)" -ForegroundColor Yellow } } }
$bashWorks = $false; try { $bashWorks = (& $bashPath -lc "grep --version" 2>$null) -ne $null } catch {}
$agentsExists = Test-Path $agentsPath
Write-Host ""; Write-Host "=== Result ==="
if ($bashWorks) { Write-Host "  Bash: OK ($bashSource)" -ForegroundColor Green } else { Write-Host "  Bash: FAIL" -ForegroundColor Red }
if ($agentsExists) { Write-Host "  AGENTS.md: OK" -ForegroundColor Green } else { Write-Host "  AGENTS.md: FAIL" -ForegroundColor Red }
if ($bashWorks -and $agentsExists) { Write-Host "Done. Restart terminal." -ForegroundColor Green } else { Write-Host "Some checks failed." -ForegroundColor Yellow }
