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

`install.fish --greeter` does all of this, and `install.fish --greeter --greeter-enable`
does the enable step too. It refuses to enable over SSH or with no `agetty-tty2..6`
left, and it substitutes the current `$USER` into the installed copy of
`greeter.qml` -- the account in the repo copy is this machine's, and the greeter
cannot ask, since it runs before anyone has logged in.

The rest of this file is what the flag does, and why each step is there.

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

# PAM service for the greeter. This one is NOT optional and does not exist by
# default: without it the greeter gets no elogind session, so libseat asks to
# take control of the LOGGED-IN user's session instead and is refused --
# "Only owner of session may take control", then "No backend was able to open a
# seat", and cage exits.
sudo install -Dm644 pam.d-greetd-greeter /etc/pam.d/greetd-greeter
```

## You cannot test this while logged in

Running `sudo greetd` from inside a running session does NOT work, and it is
not a configuration problem. The logged-in session owns `seat0`, and elogind
will not let a second session take control of a seat the active session owns:

```
libseat logind: Could not take control of session:
                Only owner of session may take control
No backend was able to open a seat
```

cage then cannot build a wlroots backend and exits, which greetd reports as
"greeter exited without creating a session". The seat is behaving correctly --
there is only one, and it is in use.

So the greeter can only be exercised with no session holding the seat, which in
practice means enabling the service and rebooting. That is safe here, and the
next section explains why.

Only the LOOK can be checked from inside a session, because a nested compositor
uses the Wayland backend instead of DRM and never asks for a seat:

```sh
cage -- qs -p /etc/greetd/greeter.qml     # opens as a window; greetd is absent,
                                          # so it renders but cannot log in
```

## Enable at boot

`install.fish --greeter-enable` picks the right one of these by init.

### runit (Artix)

```sh
sudo ln -s /etc/runit/sv/greetd /etc/runit/runsvdir/default/
sudo rm /etc/runit/runsvdir/default/agetty-tty1
```

### systemd (Arch)

```sh
sudo systemctl enable greetd.service
```

The packaged unit declares `Conflicts=getty@tty1.service`, so there is nothing
to delete -- and nothing to restore on the way out, which is why backing this
one out is a single `systemctl disable --now greetd`.

`sv/greetd/run` has no systemd equivalent to install: greetd's unit is the
package's. The one thing that script does besides `exec greetd` is create
`/run/greeter` as root before privileges drop, so that job moves to
`/etc/tmpfiles.d/greeter.conf`.

The fallback console is different too. There are no `agetty-tty2..6` services
to keep enabled -- logind spawns a getty when you switch VT, so `Ctrl+Alt+F2`
works unless `NAutoVTs=0` is set, which is the only thing the installer checks
for here.

Then reboot. **agetty-tty2 .. agetty-tty6 stay enabled**, and that is the whole
safety net: if the greeter fails to come up, vt1 is blank but `Ctrl+Alt+F2` is
still a working text login, from which the next section backs the change out.
Do not disable those, and do not do this over SSH-only access.

## Back out

```sh
sudo rm /etc/runit/runsvdir/default/greetd
sudo ln -s /etc/runit/sv/agetty-tty1 /etc/runit/runsvdir/default/
```

## Input devices

The `greeter` user needs `input` as well as `video`:

```sh
sudo usermod -aG input greeter
```

With the PAM service in place elogind brokers a seat and this may not be
needed, but it is harmless and removes one variable.

## Seats, if it still fails

`seatd` is installed here and could host the seat instead of elogind, but it
needs its own runit service and the `greeter` user in the `seat` group. The PAM
route above is preferred: no extra daemon, and it leaves how the main session
gets its seat completely untouched.

## When it fails and you cannot see why

greetd swallows the greeter's stderr, so the session is wrapped to log to
`/run/greeter/session.log`. Read that after a failed attempt; it is where cage
and Quickshell actually say what went wrong.

## What it launches

On success it runs `Hyprland`. Change the `Greetd.launch([...])` call in
`greeter.qml` if that ever stops being the session you want.
