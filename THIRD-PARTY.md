# Third-party pieces

Everything here is built from a git repo rather than installed from Arch's repos, the
AUR, or OpenBSD ports. Each one is a liability: an unpackaged dependency that nobody
else is watching, pinned to an ABI that upstream can move. So each entry has to say
**why it is worth it** and **what breaks if it dies**.

Rule of thumb: if a packaged tool does the job, use the packaged tool. See the many
"not in OpenBSD ports" notes in `linux/.config/` for the decisions that went the other
way.

| what | repo | why | if it dies |
|---|---|---|---|
| *(none yet)* | | | |

## Evaluated and rejected

**Firedecor** — `AhoyISki/Firedecor`. An advanced wayfire decoration plugin: PNG button
themes, rounded corners, per-edge decorations. It is the only way to get real
always-coloured macOS traffic lights on wayfire, because wayfire's built-in decorator
has no button-image support.

**Rejected: the repo is ARCHIVED.** Last actual code commit 2024-01-23 (the 2025 commits
are README-only), and wayfire's plugin ABI has moved several releases since — wayfire is
0.11.0 now. Of 30-odd forks, exactly one has been touched in the last year
(`cjlester41/Firedecor`) and it is not a maintained continuation. A decoration plugin
that fails to load takes the titlebars with it.

What wayfire's built-in decorator gives instead: buttons ARE already circles
(`cairo_arc` in `plugins/decor/deco-theme.cpp`), with a hover animation, and it does
expose `title_height`, `border_size`, `button_order`, `button_scale`, `active_color`,
`inactive_color`, `font` and `font_color` — so the titlebar itself is themable by coat.

The gap is the button colours. They are hardcoded in C++ and only applied on hover:

    close    rgb(242,  80,  86)   #F25056
    minimize rgb(250, 198,  54)   #FAC636
    maximize rgb( 57, 234,  73)   #39EA49

which is the *inverse* of macOS — colour on hover, neutral at rest. Getting
always-coloured, scheme-driven lights would mean patching wayfire itself and maintaining
that patch against every release. Not done; revisit if a maintained decoration plugin
appears.

**wayfire-plugins-extra** — packaged in Arch, but at 0.9.0 against wayfire 0.11.0.
Wayfire plugins are ABI-tied to the compositor, so it is unlikely to load. Not a
third-party build, listed here only so nobody assumes it is available.
