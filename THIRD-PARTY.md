# Third-party pieces

Anything built from a git repo rather than installed from Arch's repos, the AUR, or
OpenBSD ports. Each one is a liability — an unpackaged dependency nobody else is
watching, often pinned to an ABI upstream can move — so each entry has to say **why it
is worth it** and **what breaks if it dies**.

Availability check order before concluding something is unavailable: official repos →
AUR (`paru -Ss`) → upstream git. Only the third belongs in this file.

| what | repo | why | if it dies |
|---|---|---|---|
| *(none)* | | | |

## Evaluated and not used

**pixdecor** — [soreau/pixdecor](https://github.com/soreau/pixdecor). Maintained, by a
wayfire maintainer, and genuinely good: rounded corners, drop shadows, left-side
titlebar buttons, per-button PNG images. It was set up and then dropped on 2026-08-18
along with wayfire itself, because **mango does corners, shadows, blur and animations
natively** — so the plugin was solving a problem that only existed while wayfire was the
compositor. Nothing here needs building from git any more.

**Firedecor** — `AhoyISki/Firedecor`. The older equivalent of pixdecor, and **archived**:
last code commit 2024-01-23, against a much older wayfire plugin ABI. Superseded by
pixdecor and then by not needing either.

**wayfire-plugins-extra** — packaged in Arch but at 0.9.0 against wayfire 0.11.0. Wayfire
plugins are ABI-tied to the compositor, so it would not have loaded. Moot now.

## The rule this file exists to enforce

"Not in a repo" is **not** a reason to reject something — the AUR exists, and a git repo
is an acceptable dependency when it earns its place. Legitimate reasons to reject:
unmaintained *and* ABI-incompatible, or a real cost like per-frame GPU work on a
battery-first laptop. The reason this table is empty is neither of those: the compositor
just does it all already.
