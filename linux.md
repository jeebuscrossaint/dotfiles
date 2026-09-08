# Linux

**Requirements:** GNU Stow, [coat](https://github.com/jeebuscrossaint/coat)

```sh
./install.sh          # stow -t ~ linux, then `coat apply`
stow -t ~ linux       # symlinks only, no theming
stow -D -t ~ linux    # uninstall
```

`linux/` is a single stow package: its tree mirrors `$HOME`, so
`linux/.config/kitty/kitty.conf` becomes `~/.config/kitty/kitty.conf`.

## Stack

| | | |
|---|---|---|
| compositor | **mango** | dwl-based, dwm tag model. Effects switched off at their master keys, every knob left tuned underneath |
| bar | *none* | **conky** draws the readout on the desktop layer — visible on an empty tag, never covering a window |
| notifications | **fnott** | also draws the volume/brightness OSD, via `~/.local/bin/osd` |
| launcher | **fuzzel** | bound directly in `config.conf`, no wrapper |
| lock / idle | **swaylock** + **swayidle** | the only Wayland locker in both Arch and OpenBSD ports |
| login | *none* | agetty on tty1; `mango-run` starts the session |
| terminal | **kitty** | coat writes `coat-theme.conf`; `kitty @ set-colors` recolours live |
| shell | **fish** | |
| editor | **nvim** | lazy.nvim |
| theming | **coat** | one command recolours every app below, live |

## One compositor

**mango, and only mango.** labwc and wayfire were both tried as a second stacking session
in August 2026 and both removed on 2026-08-18, because mango turned out to already do
everything they were brought in for:

| | mango | labwc | wayfire |
|---|---|---|---|
| blur | **yes** | no | yes |
| drop shadows | **yes** | yes | no (needs a git plugin) |
| rounded corners | **yes** | yes | no (needs a git plugin) |
| animations | **yes** | no | yes |
| overview / exposé | **yes** (`toggleoverview`) | no | yes |
| in OpenBSD ports | **yes** | yes | yes |
| coat-themed | **yes** | yes | yes |
| titlebars | no | yes (traffic lights) | yes (buttons stuck right) |

The one thing mango genuinely cannot do is titlebars — it is dwl-derived, so there are no
server-side decorations and no traffic lights. That is the entire price, and it bought
back a single compositor instead of three configs, three validators and a git-built
plugin.

Start it from a TTY with `mango-run`. `Super+Shift+W` flips a tag to all-floating if a
stacking desktop is wanted; `Super+O` is the overview.

The effects block in `mango/config.conf` is OFF — `animations`, `blur`, `shadows` and
`border_radius` are all 0, with every tuned value left in place under them. Blur was
a per-frame shader pass on a 2560x1600 240Hz panel and cost real battery; turn them
back on one master key at a time if you want them.

## Layout

```
linux/
├── .config/
│   ├── coat/          scheme + module list; drives everything else
│   ├── mango/         the compositor: binds, layouts, effects, monitors, autostart
│   ├── waybar/        bar config + stylesheet
│   ├── fnott/         notifications and OSD
│   ├── fuzzel/        launcher (colours patched in place by coat)
│   ├── swaylock/      the locker (colours patched in place by coat)
│   ├── conky/         the desktop readout that replaced the bar
│   ├── kitty/ fish/  nvim/  bat/  btop/  zathura/  gtk-3.0/  gtk-4.0/  paru/
│   └── ...
└── .local/
    ├── bin/           session scripts — see below
    └── share/icons/   macOS cursor theme
```

Files coat *generates* (`coat-colors.conf`, `coat-colors.css`, `coat-theme.ini`,
`fnott.ini` and the colour keys it patches into `fuzzel.ini`)
are gitignored or patched in place. Only hand-written config
is tracked, so a scheme change never shows up as a diff.

## `.local/bin`

| | |
|---|---|
| `mango-run` | start the session from a TTY |
| `audio-ensure` | repair the audio stack, but only when it is genuinely dead |
| `mango-tags`, `mango-title` | stream tags and title over `mmsg watch` — only used if you start waybar |
| `waybar-fan`, `waybar-uptime` | fan RPM and uptime; `status` reads both |
| `osd` | perform a volume/brightness/lock-key change *and* draw it as a notification |
| `theme-pick`, `theme-random` | coat scheme pickers |
| `screenshot`, `screenshot-edit` | region grab; `-edit` pipes to satty |
| `prime-run` | run one app on the dGPU |
| `start-polkit`, `refresh-paru-completions` | session odds and ends |

## Retired

Kept here so nothing gets reintroduced by reflex. Every one of these was replaced
because it could not be recoloured live, or needed a supervisor process to
survive being recoloured:

**sway/swaybar** → mango/waybar · **dwl** → mango (compile-time config) ·
**foot** → **kitty** · **tofi** → wmenu → **fuzzel** (tofi is not in OpenBSD ports; wmenu has no
.desktop support and no config file) · **gtklock** → hyprlock → **swaylock** (the only one in OpenBSD ports too) ·
**dunst** → fnott · **labwc**, **wayfire** → mango does it all natively ·
**swayrbar**, **slstatus**, **barstat** → native waybar
modules · **ashell** · **avizo**, **swayosd**, **wob** → the OSD is a
notification now · **kanshi** → mango's `monitorrule` ·
**Hyprland** → back to mango, 2026-09-08 · **Quickshell** (bar, dock, Spotlight,
Mission Control, notifications, lock, greeter) → deleted the same day: no bar at
all, `fnott` for notifications, `fuzzel` for launching ·
**greetd** + the QML greeter, then briefly **tuigreet** → no greeter at all; agetty
on tty1 and `mango-run` · **wlopm**, **hypridle** → no blanking, swayidle only ·
**waybar** → kept installed and configured, but nothing starts it

The reasoning for each is in the config file that replaced it, and the module
list at the top of `.config/coat/coat.yaml`.
