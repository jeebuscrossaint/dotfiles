# pkg — vendored, compile-time-configured software

One tree left. These are source trees, not packages: slstatus is configured by
editing a C header and recompiling, so the source has to live here rather than
being installed from a repo. `config.def.h` **is** the configuration and is
tracked; `config.h` is generated from it at build time and is not.

## Setup on a new machine

```sh
make deps        # report any missing build dependencies
make install     # build + install into ~/.local, no root needed
```

`PREFIX` defaults to `~/.local`. Override it if you want (`make install
PREFIX=/usr/local`, which then does need root).

## What is here

| tree | what it is | replaces |
|---|---|---|
| `slstatus` | status line generator | swayrbar |

`local-patches/slstatus/` holds our own commits exported with `git format-patch`,
one file per change, with the reasoning in each commit message.

## What used to be here, and why it is not

The compositor is **mango** now, packaged on both Arch (AUR: `mangowm`) and
OpenBSD (`wayland/mango`), so it needs no vendoring — which was the whole point
of switching to it.

- **dwl** — replaced by mango. dwl is compile-time configured, so every keybind
  change cost a rebuild and a session restart, and it is not in OpenBSD ports at
  all. mango is dwl underneath with a runtime config and hot reload.
- **wl-restart** — only existed to supervise dwl across a crash and hand it back
  its Wayland socket. Nothing to supervise now.
- **wlock**, **widle**, **tsubu** — never actually run. The locker is swaylock,
  the idle daemon is swayidle, notifications are fnott. All three are in both
  Arch's repos and OpenBSD ports.
- **ww** — replaced by swaybg. ww could not survive its output being destroyed:
  its `registry_global_remove()` and `layer_surface_closed()` handlers were empty
  stubs, so a suspend left the wallpaper gone until something restarted it. It
  still lives at github.com/jeebuscrossaint/ww.
- **patches/** — upstream dwl patches, gone with dwl.

## Why slstatus stayed

It feeds waybar's status module. `slstatus -s` streams one line per second on
stdout, which is exactly what a waybar `custom` module in continuous mode
consumes, so the entire right-hand side of the bar needs no waybar configuration
at all.

It also reuses `~/.config/swayrbar/barstat` for the fields that script already
does well, grouped into four `barstat all …` calls; the fields swayrbar drew with
its own modules (wifi, cpu/mem/load, clock) use slstatus' native C readers.

And it is one of the few status generators that builds on OpenBSD as well as
Linux — its `vol_perc` reader is sndio-only, which is a hint about who it was
written for.

## Theming

Colours and fonts come from **coat**. slstatus has no colour of its own (the bar
draws it), so what coat themes here is the font and the bar around it. The
compositor, bar, locker, notifications and OSD are all themed as separate coat
modules against runtime config files — no rebuild, unlike the dwl arrangement
this replaced.
