# pkg — vendored, compile-time-configured software

These are source trees, not packages. Each is configured by editing a C header
and recompiling, so the source has to live in the dotfiles rather than being
installed from a repo. `config.def.h` in each tree **is** the configuration and
is tracked; `config.h` is generated from it at build time and is not.

## Setup on a new machine

```sh
make deps        # report any missing build dependencies
make install     # build + install into ~/.local, no root needed
```

Then start a session from a TTY:

```sh
dwl-run
```

`PREFIX` defaults to `~/.local`. Override it if you want (`make install PREFIX=/usr/local`,
which then does need root).

## What is here

| tree | what it is | replaces |
|---|---|---|
| `dwl` | wlroots compositor, dwm's model. dwl 0.8 + 25 patches | sway |
| `slstatus` | status line generator | swayrbar |
| `tsubu` | daemonless notifications | dunst (partly — see below) |
| `widle` | run a command on idle | swayidle |
| `wlock` | session locker | gtklock |
| `ww` | wallpaper setter — your own, github.com/jeebuscrossaint/ww | swaybg |

`patches/` holds the upstream patch files applied to dwl.
`local-patches/` holds our own commits exported with `git format-patch`, one file
per change, with the conflict resolutions explained in each commit message.

## wlock needs root

wlock verifies passwords against `/etc/shadow`, which only root can read, so it
must be setuid root. Installed into `~/.local` it is owned by you and refuses to
run, exiting with `getspnam failed, ensure suid & sgid lock`. It fails *before*
engaging the lock, so a broken install cannot lock you out — it just does
nothing. To actually use it:

```sh
make install-wlock-suid     # the one target here that needs root
```

## tsubu does not fully replace dunst

tsubu has **no D-Bus support at all** — it is a one-shot command that draws a
notification, not an implementation of `org.freedesktop.Notifications`. Anything
that notifies over D-Bus (Firefox, vesktop, `notify-send`) needs a real daemon,
so dunst has to stay for those.

Where tsubu is a genuine improvement is the OSD, which is script-driven:
`~/.local/bin/osd` calls `dunstify` directly, so it could call tsubu instead.
Two dunst features would need replacing:

- **stack tag / replace-in-place** — mashing a volume key currently updates one
  popup. tsubu is one process per notification, so the script would need to
  `pkill -x tsubu` before spawning the next one.
- **progress bar** (`int:value:N`) — tsubu has no value hint, so a level meter
  would have to be drawn as text.

## ww

Vendored from your own repo, with a plain `Makefile` added (upstream builds with
xmake, which is another dependency and does not fit clone-and-make) and
`stb_image.h` vendored into `inc/` since the `stb` package is not installed.

Four bugs fixed while integrating:

- **`--output` never worked.** `wl_output` was bound at version 3, but the
  `wl_output.name` event that carries the connector name (`eDP-1`) only exists
  from version 4, so the listener never fired and every output reported as
  `Unknown`. Now binds `min(version, 4)` and falls back to the model string.
- **An unmatched `--output` hung forever** instead of erroring: it matched no
  output, created no surface, then blocked in the event loop waiting for a
  configure that could never arrive.
- **TIFF loading used uninitialised dimensions.** `TIFFGetField`'s return value
  was ignored and `img` comes from `malloc`, so a malformed file allocated from
  whatever was on the heap. Also `w * h` was computed in `int`.
- **`ftell` results were assigned straight to `size_t`**, so a directory (ftell
  returns -1) became a SIZE_MAX allocation reported as out-of-memory.

Also bounded the transition frame-copy by the allocated buffer size rather than
by `width * height` — the transition only starts when those agree, but nothing
re-checks it, and an output resize mid-transition would run off the mapping.

## How the pieces connect

- dwl's bar reads status text from **dwl's own stdin**, so slstatus is piped in
  by `dwl-run` rather than started from dwl's `autostart[]`.
- slstatus reuses `~/.config/swayrbar/barstat` for the fields that script already
  does well, grouped into four `barstat all …` calls. Fields swayrbar drew with
  its own modules (wifi, cpu/mem/load, clock) use slstatus' native C readers.
- Colours and fonts come from **coat**. A tree that is themed includes a
  generated header (`~/.config/dwl/coat-colors.h`) found via a
  `-I$(HOME)/.config/<tool>` in its Makefile, guarded with `__has_include` so a
  fresh clone builds before coat has ever run, falling back to the framer values
  baked into `config.def.h`.
- Because these are compile-time configured, `coat set <scheme>` **rebuilds**
  them. dwl is not restarted automatically — that would kill the session — so
  restart it yourself (`Super+Shift+r`) to see a scheme change.

## Updating a tree from upstream

There is no git history here (these are vendored, not submodules), so an
upstream bump is:

1. Clone the new upstream release somewhere scratch.
2. Re-apply the patch files in `patches/` in the order listed in
   `local-patches/dwl/` (the filenames are numbered in application order).
3. Re-do the conflict resolutions — each `local-patches/dwl/*.patch` commit
   message records what was decided and why.
4. Copy your `config.def.h` across and diff it against the new `config.def.h`
   from upstream, since patches often restructure it.

Order matters for dwl: `bar` must be applied first, as it restructures
`config.h`.

## Dependency note

dwl 0.8 builds against **wlroots 0.19 specifically**. Artix ships 0.18, 0.19 and
0.20 as coexisting packages, so having 0.20 installed for sway does *not* satisfy
dwl. `make deps` checks for the right one.
