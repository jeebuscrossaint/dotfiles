# Windows Dotfiles Installer

Write-Host "[INFO] Installing Windows dotfiles..." -ForegroundColor Blue

$DOTFILES_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$WINDOWS_DIR  = Join-Path $DOTFILES_DIR "windows"

function Link-Config {
    param($Source, $Target)
    if (-not (Test-Path $Source)) { return }
    $dir = Split-Path -Parent $Target
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Copy-Item -Path $Source -Destination $Target -Force
    Write-Host "[OK] $Target" -ForegroundColor Green
}

# PowerShell profile
Link-Config `
    (Join-Path $WINDOWS_DIR "Microsoft.PowerShell_profile.ps1") `
    (Join-Path $env:USERPROFILE "Documents\PowerShell\Microsoft.PowerShell_profile.ps1")

# GlazeWM
Link-Config `
    (Join-Path $WINDOWS_DIR "glazewm\config.yaml") `
    (Join-Path $env:USERPROFILE ".glzr\glazewm\config.yaml")

# lf
Link-Config `
    (Join-Path $WINDOWS_DIR "lf\lfrc") `
    (Join-Path $env:LOCALAPPDATA "lf\lfrc")

# btop
Link-Config `
    (Join-Path $WINDOWS_DIR "btop\btop.conf") `
    (Join-Path $env:APPDATA "btop\btop.conf")

# Windows Terminal
Link-Config `
    (Join-Path $WINDOWS_DIR "windows-terminal\settings.json") `
    (Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json")

# GlazeWM autostart
$glazewmPath = (Get-Command glazewm -ErrorAction SilentlyContinue)?.Source
if ($glazewmPath) {
    $startupDir = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    $shortcut = "$startupDir\GlazeWM.lnk"
    $wsh = New-Object -ComObject WScript.Shell
    $lnk = $wsh.CreateShortcut($shortcut)
    $lnk.TargetPath = $glazewmPath
    $lnk.Save()
    Write-Host "[OK] GlazeWM autostart registered" -ForegroundColor Green
} else {
    Write-Host "[SKIP] glazewm not found on PATH, skipping autostart" -ForegroundColor Yellow
}

Write-Host "[INFO] Done!" -ForegroundColor Blue
