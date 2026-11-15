# Windows Dotfiles Installer

$profileSrc = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "windows\Microsoft.PowerShell_profile.ps1"
$profileDst = Join-Path $env:USERPROFILE "Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

New-Item -ItemType Directory -Path (Split-Path -Parent $profileDst) -Force | Out-Null
Copy-Item -Path $profileSrc -Destination $profileDst -Force
Write-Host "[OK] $profileDst" -ForegroundColor Green

# Rainmeter: the conky panels (windows\rainmeter) and their layout.
# Skins and layout are JUNCTIONED, not copied, so edits in the repo are live.
# Rainmeter.ini itself is not linked: Rainmeter rewrites it on every move, so
# the tracked layout is loaded over it instead.
$rmSrc = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "windows\rainmeter"
if (-not (Get-Command rainmeter -ErrorAction SilentlyContinue)) {
    scoop bucket add extras 2>$null
    scoop install extras/rainmeter
}
$rmHome = Join-Path $env:USERPROFILE "scoop\persist\rainmeter"
$rmExe  = Join-Path $env:USERPROFILE "scoop\apps\rainmeter\current\Rainmeter.exe"
foreach ($link in @(
    @{ Path = "$rmHome\Skins\conky";   Target = "$rmSrc\conky" },
    @{ Path = "$rmHome\Layouts\conky"; Target = "$rmSrc\Layouts\conky" }
)) {
    New-Item -ItemType Directory -Path (Split-Path -Parent $link.Path) -Force | Out-Null
    if (Test-Path $link.Path) { (Get-Item $link.Path).Delete() }
    New-Item -ItemType Junction -Path $link.Path -Target $link.Target | Out-Null
    Write-Host "[OK] $($link.Path)" -ForegroundColor Green
}
# Colours: coat writes ~/.config/rainmeter/coat.inc when `rainmeter` is in coat.yaml's enabled list.
if (Get-Command coat -ErrorAction SilentlyContinue) { coat apply rainmeter | Out-Null }
if (-not (Get-Process Rainmeter -ErrorAction SilentlyContinue)) { Start-Process $rmExe; Start-Sleep 3 }
& $rmExe !LoadLayout conky
Write-Host "[OK] Rainmeter layout: conky" -ForegroundColor Green
