# optimize-admin.ps1 - System-level optimizations (requires admin)
# Called by setup.ps1

# Defender exclusions for dev directories
$devDirs = @(
    "$env:USERPROFILE\scoop"
    "$env:USERPROFILE\.dotnet"
    "$env:USERPROFILE\AppData\Local\UnrealEngine"
    "$env:USERPROFILE\AppData\Roaming\npm"
    "C:\Program Files\dotnet"
    "D:\UnrealProjects"
    "D:\UE"
    "D:\code"
    "D:\Microsoft Visual Studio"
    "D:\JetBrains"
)
foreach ($d in $devDirs) {
    if (Test-Path $d) {
        Add-MpPreference -ExclusionPath $d -ErrorAction SilentlyContinue
        Write-Host "Defender excluded: $d"
    }
}

# NTFS: disable last access timestamp
fsutil behavior set disablelastaccess 1 2>$null
Write-Host "NTFS last access disabled"

# Developer mode (symlinks without admin)
Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' -Name 'AllowDevelopmentWithoutDevLicense' -Value 1 -ErrorAction SilentlyContinue
Write-Host "Developer mode enabled"

# Power plan: High Performance
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
Write-Host "Power plan: High Performance"


# Machine PATH: put bash dir first so `bash` resolves to the real bash
# (e.g. MSYS2) instead of C:\Windows\System32\bash.exe (WSL), which
# precedes all user-PATH entries and hangs when its stdio is piped.
if ($BashDir) {
    $bashDirN = $BashDir.TrimEnd('\')
    $mp = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $parts = $mp -split ';' | ForEach-Object { $_.TrimEnd('\') }
    if ($parts -notcontains $bashDirN) {
        [Environment]::SetEnvironmentVariable('Path', ($bashDirN + ';' + $mp), 'Machine')
        Write-Host "Machine PATH patched: bash dir moved before System32"
    } else {
        Write-Host "Machine PATH order OK"
    }
}
Write-Host "All system optimizations applied."





