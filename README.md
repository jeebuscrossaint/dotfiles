# dotfiles

mango · conky · kitty · fish · micro · fuzzel · dunst · coat

arch linux

---

**deps:** git, fish, [coat](https://github.com/jeebuscrossaint/coat)

```sh
git clone https://github.com/jeebuscrossaint/dotfiles ~/dotfiles
~/dotfiles/install.fish
```

The installer installs the packages, symlinks every tracked file in `linux/` into
`~` (one link per file, so directories in `~` stay real), then applies coat. It
backs up (or, with `--adopt`, absorbs) anything already sitting where a link
belongs, removes links to files the repo no longer has, and verifies the links
afterwards. `--dry-run`, `--uninstall` and `-h` do what they say.

On a fresh machine it first checks everything the tracked configs actually call
— binaries, fonts, the polkit agent — prints the missing ones grouped, and hands
you the exact `pacman`/`paru` line for them (or offers to run it). It also offers
to download the whole Nerd Fonts release. `./install.fish --check` is that report
on its own.

```sh
./install.fish --skip-checks --no-coat   # links only, no packages, no theming
./install.fish --uninstall               # remove the links
```

`linux/` mirrors `$HOME`, so
`linux/.config/kitty/kitty.conf` becomes `~/.config/kitty/kitty.conf`.

## Stack

| | | |
|---|---|---|
| compositor | **mango** | dwl-based, dwm tag model. Blur, shadows, rounded corners and animations on |
| bar | *none* | **conky** draws the readout on the desktop layer — visible on an empty tag, never covering a window |
| notifications | **dunst** | also draws the volume/brightness OSD, via `~/.local/bin/osd` |
| launcher | **fuzzel** | bound directly in `config.conf`, no wrapper |
| lock / idle | **swaylock** + **swayidle** | coat's colours arrive as flags, from `idle-guard` |
| login | *none* | agetty on tty1; `mango-run` starts the session |
| terminal | **kitty** | coat writes `coat-theme.conf`; `kitty @ set-colors` recolours live |
| shell | **fish** | |
| editor | **micro** | |
| files | **yazi** | |
| theming | **coat** | one command recolours every app below, live |

Start it from a TTY with `mango-run`. `Super+Shift+W` flips a tag to all-floating
if a stacking desktop is wanted; `Super+O` is the overview carousel.

**mango, and only mango.** labwc and wayfire were both tried as a second stacking
session and removed, because mango already does blur, shadows, rounded corners,
animations and an overview natively. The one thing it cannot do is titlebars — it
is dwl-derived, so there are no server-side decorations.

## Layout

```
linux/
├── .config/
│   ├── coat/          scheme + module list; drives everything else
│   ├── mango/         the compositor: binds, layouts, effects, monitors, autostart
│   ├── dunst/         notifications and OSD
│   ├── fuzzel/        launcher (coat theme pulled in with include=)
│   ├── swaylock/      the locker (coat theme passed as flags by idle-guard)
│   ├── conky/         the desktop readout that replaced the bar
│   ├── kitty/ fish/ micro/ yazi/ mpv/ bat/ btop/ zathura/ gtk-3.0/ gtk-4.0/ paru/
│   └── ...
└── .local/
    ├── bin/           session scripts — see below
    └── share/icons/   macOS cursor theme
```

Files coat *generates* (`coat-colors.conf`, `coat-colors.css`, `coat-theme.ini`,
`dunstrc.d/50-coat.conf`, `swaylock/coat-theme.conf`) sit beside the hand-written
config and are pulled in by an `include`, a drop-in directory, or the command
line. **No coat module edits a tracked file**, and the config directories it
writes into are real directories, so a scheme
change never shows up as a diff.

## `.local/bin`

| | |
|---|---|
| `mango-run` | start the session from a TTY |
| `audio-ensure` | repair the audio stack, but only when it is genuinely dead |
| `osd` | perform a volume/brightness/lock-key change *and* draw it as a notification |
| `theme-pick`, `theme-random` | coat scheme pickers |
| `screenshot`, `screenshot-edit` | region grab (`Super+Shift+S`); `-edit` pipes to satty (`Super+Shift+E`) |
| `idle-guard` | lock now, handing swaylock the current wallpaper |
| `start-polkit`, `refresh-paru-completions`, `battery-watch` | session odds and ends |

## Retired

Kept here so nothing gets reintroduced by reflex. Every one of these was replaced
because it could not be recoloured live, or needed a supervisor process to
survive being recoloured:

**sway/swaybar** → mango, and conky for the readout · **dwl** → mango (compile-time config) ·
**foot** → **kitty** · **nvim** → **micro** · **tofi** → wmenu → **fuzzel** ·
**gtklock** → hyprlock → **swaylock** · **fnott** → **dunst**, for the drop-in
directory coat themes it with · **labwc**, **wayfire** → mango does it all natively ·
**swayrbar**, **slstatus**, **barstat**, **waybar** → conky · **avizo**, **swayosd**,
**wob** → the OSD is a notification now · **kanshi** → mango's `monitorrule` ·
**Hyprland** + **Quickshell** → back to mango, no bar at all ·
**greetd**, **tuigreet** → no greeter; agetty on tty1 and `mango-run` ·
**wlopm**, **hypridle** → no blanking, swayidle only

The reasoning for each is in the config file that replaced it, and the module
list at the top of `.config/coat/coat.yaml`.

## Minecraft

One instance: **1.8.9 PvP**, Forge 11.15.1.2318 on Java 8, in PrismLauncher.
Mostly Polyfrost/OneConfig, plus OptiFine. Only the mods are tracked —
`minecraft/mods.txt` plus Prism's `.index` metadata. Settings, saves and resource
packs are not in the repo.

```sh
./install.fish --minecraft
```

Creates the instance if it isn't there (3G heap), fetches the mods, and leaves an
instance Prism picks up on next start. Safe to run against an instance you made
yourself — it only writes `instance.cfg` and `mmc-pack.json` when they're absent,
and skips entirely if jars are present.

By hand, minus OptiFine:

```fish
set mods ~/.local/share/PrismLauncher/instances/1.8.9/minecraft/mods
mkdir -p $mods
wget -P $mods --content-disposition -i ~/dotfiles/minecraft/mods.txt
cp -r ~/dotfiles/minecraft/.index $mods/
```

`--content-disposition` is not optional: without it wget names files after the
URL's query string instead of the jar, and Forge ignores them. `.index/` makes
Prism list them as managed mods with update buttons rather than anonymous jars.

**OptiFine** is deliberately not in `mods.txt`. optifine.net puts an ad page in
front of the jar and the real URL carries a token that rotates within minutes. A
stale token answers `200` with a 19-byte `Request not found.` body, which wget
saves as the jar without complaint. `install.fish` scrapes a fresh token from the
ad page instead (with a browser User-Agent) and checks the result starts with the
`PK` zip magic before keeping it.

| Mod | Version |
|---|---|
| 3D Skin Layers | 1.2.0 |
| Animatium Legacy (OverflowAnimations) | 2.2.5 |
| ArmorHUD | 1.1 |
| Autotip | 1.0.0 |
| BehindYou (SnapLook) | 3.2.2 |
| Canelex Keystrokes Revamp | 1.0.0 |
| Chatting | 2.0.6 |
| ColorSaturation | 1.0.0 |
| CrashPatch | 2.0.2 |
| DamageTint | 3.3.0 |
| Essential | forge_1.8.9 |
| GlintColorizer | 2.0.1 |
| Hytils Reborn | 1.7.5 |
| Lunar Block Overlay | 2.1.0 |
| No Hurt Cam | 1.0.0 |
| OneConfig | 0.2.2 (+bootstrap 1.0.3) |
| OptiFine | 1.8.9 HD U L5 |
| Patcher (PolyPatcher) | 1.10.4 |
| PolyBlur | 1.0.2 |
| PolyCrosshair | 1.0.3 |
| PolyHitbox | 1.0.3 |
| PolyNametag | 1.0.10 |
| PolySprint | 1.0.2 |
| PolyTime | 1.0.2 |
| PolyWeather | 1.0.0 |
| TabStats | 1.3.0 |
| TNT Countdown | 1.4.1-alpha |
| Wavey Capes | 1.2.0 |

Disabled, kept on disk as `.jar.disabled` and so left out of `mods.txt`: Better
Chat 1.5, OverflowParticles 1.0.2, VanillaHUD 2.2.12 (the OneConfig HUD replaced
it). Their URLs are in their `.pw.toml`. MurderMysteryPlus 0.17.0 is installed
but not tracked.

## Windows

Install [Scoop](https://scoop.sh) and the packages:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
scoop bucket add extras
scoop install pwsh uutils-coreutils git bat fastfetch gh
```

`.\install.ps1` copies the PowerShell profile into place; it removes PowerShell
aliases that shadow a real executable, so uutils commands win.

---

**extensions:** uBlock Origin · SponsorBlock · BetterCanvas · Return YouTube Dislike · Proton Pass · Dark Reader · Adaptive Tab Bar Color · Imagus

**wallpapers**

- https://github.com/rann01/IRIX-tiles
- https://github.com/dharmx/walls
- https://github.com/wallace-aph/tiles-and-such
- https://github.com/tile-anon/tiles
- https://github.com/peteroupc/classic-wallpaper
- https://github.com/makccr/wallpapers
- https://github.com/whoisYoges/lwalpapers
- https://github.com/Axenide/Wallpapers
