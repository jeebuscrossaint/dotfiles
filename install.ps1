# Windows Dotfiles Installer

$profileSrc = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "windows\Microsoft.PowerShell_profile.ps1"
$profileDst = Join-Path $env:USERPROFILE "Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

New-Item -ItemType Directory -Path (Split-Path -Parent $profileDst) -Force | Out-Null
Copy-Item -Path $profileSrc -Destination $profileDst -Force
Write-Host "[OK] $profileDst" -ForegroundColor Green
