#Requires -Version 5.1
# uninstall.ps1 - fully remove use-bash and restore the original state.
# Restores from ~/.codex/use-bash-backup.json when available; falls back to
# safe defaults (unset the git keys this skill sets, remove only the PATH
# entry it added) when no backup exists.
param([switch]$KeepBackup)
$ErrorActionPreference = "Continue"
Write-Host "=== use-bash uninstall ===" -ForegroundColor Cyan
$agentsDir = "$env:USERPROFILE\.codex"
$backupPath = "$agentsDir\use-bash-backup.json"
$state = $null
if (Test-Path $backupPath) {
  try { $state = Get-Content $backupPath -Raw | ConvertFrom-Json } catch { Write-Host "  Backup unreadable, using fallback defaults." -ForegroundColor Yellow }
}
Write-Host "[1/8] Restoring AGENTS.md..."
if ($state -and $state.agentsMdExists) {
  if (Test-Path "$agentsDir\AGENTS.md.use-bash-bak") {
    Move-Item "$agentsDir\AGENTS.md.use-bash-bak" "$agentsDir\AGENTS.md" -Force
    Write-Host "  AGENTS.md restored from backup" -ForegroundColor Green
  } else {
    Write-Host "  Backup copy missing; original AGENTS.md left in place" -ForegroundColor Yellow
  }
} else {
  Remove-Item "$agentsDir\AGENTS.md" -Force -ErrorAction SilentlyContinue
  Write-Host "  AGENTS.md deleted (did not exist before setup)" -ForegroundColor Green
}
Write-Host "[2/8] Restoring WSL bash alias..."
$winApps = "$env:USERPROFILE\AppData\Local\Microsoft\WindowsApps"
$aliasRenamed = Test-Path "$winApps\bash-wsl.exe"
$aliasWasPresent = if ($state) { $state.bashAliasState -eq "present" } else { $true }
if ($aliasRenamed -and $aliasWasPresent) {
  Rename-Item "$winApps\bash-wsl.exe" "bash.exe" -ErrorAction SilentlyContinue
  Write-Host "  bash.exe alias restored" -ForegroundColor Green
} elseif ($aliasRenamed) {
  Write-Host "  Backup says the alias did not exist before; leaving bash-wsl.exe removed state" -ForegroundColor Yellow
} else {
  Write-Host "  No renamed alias found"
}
Write-Host "[3/8] Restoring user PATH..."
if ($state -and $state.userPath) {
  [Environment]::SetEnvironmentVariable("Path", $state.userPath, "User")
  Write-Host "  User PATH restored from backup" -ForegroundColor Green
} else {
  Write-Host "  No backup: remove the bash dir manually if setup added one. Skipping auto-edit." -ForegroundColor Yellow
}
Write-Host "[3b/8] Restoring machine PATH..."
$msysBin = "$env:USERPROFILE\scoop\apps\msys2\current\usr\bin"
if ($state -and $state.machinePath) {
  [Environment]::SetEnvironmentVariable("Path", $state.machinePath, "Machine")
  Write-Host "  Machine PATH restored from backup" -ForegroundColor Green
} else {
  $mp = [Environment]::GetEnvironmentVariable("Path","Machine")
  if ($mp) {
    $mpParts = $mp -split ";" | Where-Object { $_ -and $_.TrimEnd("\") -ne $msysBin.TrimEnd("\") }
    if ($mpParts.Count -ne ($mp -split ";").Count) {
      [Environment]::SetEnvironmentVariable("Path", ($mpParts -join ";"), "Machine")
      Write-Host "  Removed msys2 bash dir from Machine PATH" -ForegroundColor Green
    } else {
      Write-Host "  Machine PATH untouched"
    }
  }
}
Write-Host "[4/8] Restoring git config..."
$keys = @("core.autocrlf","core.longpaths","core.fscache","core.preloadindex","core.untrackedCache","core.fsmonitor","gc.auto")
foreach ($k in $keys) {
  $old = $null
  if ($state) { $old = $state.gitConfig.$k }
  if ($old) {
    git config --global $k $old 2>$null
    Write-Host "  $k = $old (restored)"
  } else {
    git config --global --unset $k 2>$null
    Write-Host "  $k unset (git default)"
  }
}
Write-Host "[5/8] Removing Defender exclusions added by setup..."
$exclusions = @(
  "$env:USERPROFILE\scoop\apps\msys2",
  "$env:USERPROFILE\AppData\Local\wsl",
  "$env:USERPROFILE\scoop\apps\nodejs",
  "$env:USERPROFILE\.dotnet",
  "$env:USERPROFILE\AppData\Local\UnrealEngine",
  "$env:USERPROFILE\AppData\Roaming\npm"
)
foreach ($e in $exclusions) {
  if (Test-Path $e) {
    Remove-MpPreference -ExclusionPath $e -ErrorAction SilentlyContinue
    Write-Host "  Removed exclusion: $e"
  }
}
Write-Host "  Note: run elevated for full effect; exclusions you added yourself are untouched." -ForegroundColor DarkGray
Write-Host "[6/8] Removing skill files..."
Remove-Item "$env:USERPROFILE\.codex\skills\use-bash" -Recurse -Force -ErrorAction SilentlyContinue
if (-not (Test-Path "$env:USERPROFILE\.codex\skills\use-bash")) { Write-Host "  Skill directory removed" -ForegroundColor Green } else { Write-Host "  Skill directory still present - delete manually" -ForegroundColor Red }
Write-Host "[7/8] Cleaning up backup manifest..."
if (-not $KeepBackup) {
  Remove-Item $backupPath -Force -ErrorAction SilentlyContinue
  Remove-Item "$agentsDir\AGENTS.md.use-bash-bak" -Force -ErrorAction SilentlyContinue
  Write-Host "  Backup manifest deleted"
} else {
  Write-Host "  Backup kept (-KeepBackup): $backupPath" -ForegroundColor Yellow
}
Write-Host "[8/8] Verify"
Write-Host "  Open a NEW terminal and run: where.exe bash"
Write-Host "  Confirm the skill folder is gone and bash resolves the way you want."
Write-Host ""
Write-Host "Done. Restart your terminal or agent app - running processes keep a stale PATH snapshot." -ForegroundColor Green

