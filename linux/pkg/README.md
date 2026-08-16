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
| `mew` | dmenu for Wayland | tofi |
| `slstatus` | status line generator | swayrbar |

`patches/` holds the upstream patch files applied to dwl.
`local-patches/` holds our own commits exported with `git format-patch`, one file
per change, with the conflict resolutions explained in each commit message.

## How the pieces connect

- dwl's bar reads status text from **dwl's own stdin**, so slstatus is piped in
  by `dwl-run` rather than started from dwl's `autostart[]`.
- slstatus reuses `~/.config/swayrbar/barstat` for the fields that script already
  does well, grouped into four `barstat all …` calls. Fields swayrbar drew with
  its own modules (wifi, cpu/mem/load, clock) use slstatus' native C readers.
- Colours and fonts come from **coat**. Each tree includes a generated header
  (`~/.config/dwl/coat-colors.h`, `~/.config/mew/coat-colors.h`) found via a
  `-I$(HOME)/.config/<tool>` in its Makefile. Both are guarded with
  `__has_include`, so a fresh clone builds before coat has ever run, falling back
  to the framer values baked into `config.def.h`.
- Because these are compile-time configured, `coat set <scheme>` **rebuilds**
  them. dwl is not restarted automatically — that would kill the session — so
  restart it yourself to see a scheme change. mew needs no restart; the next
  invocation picks it up.

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
