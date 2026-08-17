# Linux

**Requirements:** GNU Stow, [coat](https://github.com/jeebuscrossaint/coat)

```sh
./install.sh          # stow -t ~ linux, then `coat apply`
stow -t ~ linux       # symlinks only, no theming
stow -D -t ~ linux    # uninstall
```

`linux/` is a single stow package: its tree mirrors `$HOME`, so
`linux/.config/foot/foot.ini` becomes `~/.config/foot/foot.ini`.

## Stack

| | | |
|---|---|---|
| compositor | **mango** | dwl-based, dwm tag model, runtime config with hot reload |
| bar | **waybar** | native modules + `mmsg watch` streamers for tags and title |
| notifications | **fnott** | also draws the volume/brightness OSD, via `~/.local/bin/osd` |
| launcher | **wmenu** | through `~/.local/bin/menu` so it follows the colour scheme |
| lock / idle | **swaylock** + **swayidle** | |
| terminal | **foot** | |
| shell | **fish** | |
| editor | **nvim** | lazy.nvim |
| theming | **coat** | one command recolours every app below, live |

Start it from a TTY with `mango-run`, which raises the fd limit, validates the
config, keeps a log in `~/.local/state/mango/`, and wraps the session in a single
D-Bus bus.

## Layout

```
linux/
├── .config/
│   ├── coat/          scheme + module list; drives everything else
│   ├── mango/         compositor: binds, layouts, monitors, autostart
│   ├── waybar/        bar config + stylesheet
│   ├── fnott/         notifications and OSD
│   ├── swayidle/      idle → lock → screen off
│   ├── swaylock/
│   ├── foot/  fish/  nvim/  bat/  btop/  zathura/  gtk-3.0/  gtk-4.0/  paru/
│   └── ...
└── .local/
    ├── bin/           session scripts — see below
    └── share/icons/   macOS cursor theme
```

Files coat *generates* (`coat-colors.conf`, `coat-colors.css`, `coat-theme.ini`,
the `themes/` dirs, `wmenu/coat-flags`) are gitignored. Only hand-written config
is tracked, so a scheme change never shows up as a diff.

## `.local/bin`

| | |
|---|---|
| `mango-run` | start a mango session from a TTY |
| `mango-tags`, `mango-title` | stream compositor state to waybar over `mmsg watch` |
| `waybar-fan`, `waybar-uptime` | the two things waybar has no module for |
| `menu`, `menu-run` | wmenu wrappers that pick up coat's colours |
| `osd` | perform a volume/brightness/lock-key change *and* draw it as a notification |
| `theme-pick`, `theme-random` | coat scheme pickers |
| `swayscreenshot`, `swayscreenshot-edit` | region grab; `-edit` pipes to satty |
| `canvas-ical-fetch`, `canvas-ical-parse`, `canvas-notify` | Canvas assignment reminders |
| `prime-run` | run one app on the dGPU |
| `start-polkit`, `refresh-paru-completions` | session odds and ends |

## Retired

Kept here so nothing gets reintroduced by reflex. Every one of these was replaced
because it could not be recoloured live, or needed a supervisor process to
survive being recoloured:

**sway/swaybar** → mango/waybar · **dwl** → mango (compile-time config) ·
**labwc** · **tofi** → wmenu (not in OpenBSD ports) · **gtklock** → swaylock ·
**dunst** → fnott · **swayrbar**, **slstatus**, **barstat** → native waybar
modules · **ashell** · **avizo**, **swayosd**, **wob** → the OSD is a
notification now · **kanshi** → mango's `monitorrule`

The reasoning for each is in the config file that replaced it, and the module
list at the top of `.config/coat/coat.yaml`.
