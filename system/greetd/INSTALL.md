# Quickshell greeter (greetd)

The login window, laid out like the shell's lock screen. `greeter.qml` is
deliberately self-contained: greetd runs it as the `greeter` user before anyone
has logged in, and `$HOME` is mode 700, so none of the shell's `qs.*` modules or
`coat.json` are readable from there.

**The palette is therefore hardcoded and does NOT follow coat.** A scheme change
has to be copied into `greeter.qml` by hand. Making it follow would need coat to
write a world-readable palette to a root-owned path.

## Before you start

`agetty-tty2` … `agetty-tty6` must stay enabled. They are the fallback: if the
greeter fails to start, `Ctrl+Alt+F2` still gets you a login. Do not disable
them, and do not do this over SSH-only access.

## Install

```sh
sudo pacman -S --needed cage

# The greeter itself, world-readable.
sudo install -Dm644 greeter.qml /etc/greetd/greeter.qml
sudo install -Dm644 config.toml /etc/greetd/config.toml

# Drop directory for the wallpaper, owned by you so no sudo is needed later.
# $HOME is mode 700 and traversal needs +x on every parent, so nothing under
# ~/jbwallpapers is reachable from the greeter user however the file itself is
# chmodded. ~/.local/bin/awww copies each wallpaper it sets into here, so the
# login screen follows the desktop from then on.
sudo install -d -o "$USER" -g "$USER" /var/lib/greeter

# Seed it with whatever is on screen right now.
awww img "$(awww query | sed 's/.*currently displaying: image: //')"

# runit service.
sudo install -Dm755 sv/greetd/run /etc/runit/sv/greetd/run
```

## Test it WITHOUT committing to it

Running `greetd` by hand skips the runit service, so the runtime directory it
would have created has to be made first. Without it greetd exits with
"greeter exited without creating a session":

```sh
sudo install -d -m 0700 -o greeter -g greeter /run/greeter
sudo install -d -m 0700 -o greeter -g greeter /run/greeter/cache
sudo install -d -m 0700 -o greeter -g greeter /run/greeter/state

sudo sv down agetty-tty1        # release vt1
sudo greetd                     # Ctrl+C to stop; watch the output
```

/run is a tmpfs, so those directories vanish on reboot -- which is fine,
because from then on the runit service recreates them on every start.

If the greeter comes up on vt1 and logs you in, it works. If it does not, `sv up
agetty-tty1` puts things back exactly as they were.

## Enable at boot

Only once the manual test passes:

```sh
sudo ln -s /etc/runit/sv/greetd /etc/runit/runsvdir/default/
sudo rm /etc/runit/runsvdir/default/agetty-tty1
```

## Back out

```sh
sudo rm /etc/runit/runsvdir/default/greetd
sudo ln -s /etc/runit/sv/agetty-tty1 /etc/runit/runsvdir/default/
```

## Input devices

The `greeter` user needs `input` as well as `video`, and this is NOT optional:

```sh
sudo usermod -aG input greeter
```

logind grants input through a seat, but greetd's greeter is not a logind
session, so cage falls back to opening the devices directly. Without the group
it cannot, and exits -- which greetd reports only as "greeter exited without
creating a session".

## When it fails and you cannot see why

greetd swallows the greeter's stderr, so the session is wrapped to log to
`/run/greeter/session.log`. Read that after a failed attempt; it is where cage
and Quickshell actually say what went wrong.

## What it launches

On success it runs `Hyprland`. Change the `Greetd.launch([...])` call in
`greeter.qml` if that ever stops being the session you want.
