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

# A wallpaper the greeter user can actually read. $HOME is 700, so it cannot see
# ~/jbwallpapers -- without this the greeter falls back to a flat background.
sudo install -Dm644 ~/jbwallpapers/wallpapers/<pick-one>.jpg \
  /usr/share/backgrounds/login.jpg

# runit service.
sudo install -Dm755 sv/greetd/run /etc/runit/sv/greetd/run
```

## Test it WITHOUT committing to it

Start greetd by hand, on a vt that is not your current one, before enabling
anything:

```sh
sudo sv down agetty-tty1        # release vt1
sudo greetd                     # Ctrl+C to stop; watch the output
```

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

## If the greeter starts but the keyboard does nothing

The `greeter` user is in `video` but may also need `input`:

```sh
sudo usermod -aG input greeter
```

logind is running here, so it normally grants input through the seat and this is
not needed -- try it only if the greeter is visibly up and unresponsive.

## What it launches

On success it runs `Hyprland`. Change the `Greetd.launch([...])` call in
`greeter.qml` if that ever stops being the session you want.
