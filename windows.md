# Windows Setup

## Requirements

Install [Scoop](https://scoop.sh):
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```

Add buckets:
```powershell
scoop bucket add extras
```

## Install Packages

```powershell
scoop install glazewm pwsh lf btop uutils-coreutils powertoys `
              git helix bat fastfetch gh wget curl less
```

## Install Dotfiles

```powershell
git clone https://github.com/jeebuscrossaint/.dotfiles
cd .dotfiles
.\install.ps1
```

The installer copies configs to their expected locations for each tool.

## Stack

| role | tool |
|---|---|
| window manager | glazewm |
| terminal | windows terminal |
| shell | powershell 7 (pwsh) |
| prompt | custom (defined in profile) |
| launcher | powertoys run (`Alt+Space`) |
| file manager | lf |
| system monitor | btop |
| editor | helix |
| unix coreutils | uutils-coreutils |
| fetcher | fastfetch |

## Config Locations

| config | location |
|---|---|
| powershell profile | `Documents\PowerShell\Microsoft.PowerShell_profile.ps1` |
| glazewm | `~\.glzr\glazewm\config.yaml` |
| lf | `%LOCALAPPDATA%\lf\lfrc` |
| btop | `%APPDATA%\btop\btop.conf` |
| windows terminal | `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_*\LocalState\settings.json` |

## Keybindings (GlazeWM)

| key | action |
|---|---|
| `Win+Q` | open terminal |
| `Win+C` | close window |
| `Win+F` | fullscreen |
| `Win+Shift+V` | toggle floating |
| `Win+arrows` | focus direction |
| `Win+Shift+arrows` | move window |
| `Win+1-9` | switch workspace |
| `Win+Shift+1-9` | move to workspace |
| `Win+T` | toggle tiling direction |

## Notes

- The PowerShell profile auto-removes conflicting PS aliases so uutils commands take precedence
- GlazeWM hot-reloads config on save (`config_reload_on_change: true`)
- PowerToys is configured through its GUI, not tracked in dotfiles
