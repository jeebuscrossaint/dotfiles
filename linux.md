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
| compositor | **mango** | dwl-based, dwm tag model; blur, shadows, rounded corners, animations and an overview, all native |
| bar | **waybar** | native modules + `mmsg watch` streamers for tags and title |
| notifications | **fnott** | also draws the volume/brightness OSD, via `~/.local/bin/osd` |
| launcher | **fuzzel** | .desktop entries with icons; `menu` / `menu-run` wrap it |
| lock / idle | **swaylock** + **swayidle** | |
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

The effects block in `mango/config.conf` is on, and **that costs battery** — blur is a
per-frame shader pass on a 2560x1600 240Hz panel. Turn down in this order: `blur=0`,
then `shadows=0`, then `animations=0`.

## Layout

```
linux/
├── .config/
│   ├── coat/          scheme + module list; drives everything else
│   ├── mango/         the compositor: binds, layouts, effects, monitors, autostart
│   ├── waybar/        bar config + stylesheet
│   ├── fnott/         notifications and OSD
│   ├── fuzzel/        launcher (colours patched in place by coat)
│   ├── swayidle/      idle → lock → screen off
│   ├── swaylock/
│   ├── kitty/ fish/  nvim/  bat/  btop/  zathura/  gtk-3.0/  gtk-4.0/  paru/
│   └── ...
└── .local/
    ├── bin/           session scripts — see below
    └── share/icons/   macOS cursor theme
```

Files coat *generates* (`coat-colors.conf`, `coat-colors.css`, `coat-theme.ini`,
`fnott.ini`, `swaylock/config`, and the colour keys it patches into `fuzzel.ini`)
are gitignored or patched in place. Only hand-written config
is tracked, so a scheme change never shows up as a diff.

## `.local/bin`

| | |
|---|---|
| `mango-run` | start the session from a TTY |
| `audio-ensure` | repair the audio stack, but only when it is genuinely dead |
| `mango-tags`, `mango-title` | stream compositor state to waybar over `mmsg watch` |
| `waybar-fan`, `waybar-uptime` | the two things waybar has no module for |
| `menu`, `menu-run` | fuzzel wrappers — `menu` is dmenu mode for scripts, `menu-run` is the app launcher |
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
.desktop support and no config file) · **gtklock** → swaylock ·
**dunst** → fnott · **labwc**, **wayfire** → mango does it all natively ·
**swayrbar**, **slstatus**, **barstat** → native waybar
modules · **ashell** · **avizo**, **swayosd**, **wob** → the OSD is a
notification now · **kanshi** → mango's `monitorrule`

The reasoning for each is in the config file that replaced it, and the module
list at the top of `.config/coat/coat.yaml`.
