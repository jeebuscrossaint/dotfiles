# tuigreet greeter (greetd)

A text login on vt1. It replaced a Quickshell greeter on 2026-09-08, along with
the rest of the Quickshell setup, and the replacement is mostly a deletion:
tuigreet draws on the VT itself, so there is no cage, no Qt, no wlroots backend
and no seat for the login screen to fight over.

That removes, in order: `greeter.qml` (341 lines), the `/run/greeter` runtime
directory and the fake `XDG_RUNTIME_DIR`/`HOME`/cache/state pointing at it, the
`cage -d -s -m last` invocation and its decoration workarounds, the wallpaper
drop in `/var/lib/greeter` that `awww` used to feed, and the account name that
had to be templated in at install time.

Sessions come from `/usr/share/wayland-sessions`, so `mango.desktop` (shipped by
the `mangowm` package) is what you pick at the prompt. `--remember-user-session`
means you pick it once.

## Before you start

`agetty-tty2` … `agetty-tty6` must stay enabled. They are the fallback: if the
greeter fails to start, `Ctrl+Alt+F2` still gets you a login. Do not disable
them, and do not do this over SSH-only access.

## Install

`install.fish --greeter` does all of this, and `install.fish --greeter --greeter-enable`
does the enable step too. It refuses to enable over SSH or with no `agetty-tty2..6`
left.

```sh
sudo pacman -S --needed greetd greetd-tuigreet

sudo install -Dm644 config.toml /etc/greetd/config.toml

# PAM service for the greeter. NOT optional and not shipped by default: without
# it the greeter gets no elogind session, and the handoff into the real session
# fails.
sudo install -Dm644 pam.d-greetd-greeter /etc/pam.d/greetd-greeter

# runit service. It exists to create tuigreet's --remember cache as root, before
# greetd drops to the `greeter` user, which cannot create it itself.
sudo install -Dm755 sv/greetd/run /etc/runit/sv/greetd/run
```

## Testing it

Unlike the Quickshell greeter, this one can be looked at from inside a session
without any seat trouble, because it is a terminal program and opens no DRM
device:

```sh
tuigreet --cmd true      # renders in the terminal; greetd is absent, so no login
```

The full path still needs vt1 free, which in practice means enabling the service
and rebooting.

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
`/var/cache/tuigreet` as root before privileges drop, so that job moves to
`/etc/tmpfiles.d/greeter.conf`.

The fallback console is different too. There are no `agetty-tty2..6` services
to keep enabled -- logind spawns a getty when you switch VT, so `Ctrl+Alt+F2`
works unless `NAutoVTs=0` is set, which is the only thing the installer checks
for here.

Then reboot. **agetty-tty2 .. agetty-tty6 stay enabled**, and that is the whole
safety net: if the greeter fails to come up, vt1 is blank but `Ctrl+Alt+F2` is
still a working text login, from which the next section backs the change out.

## Back out

```sh
sudo rm /etc/runit/runsvdir/default/greetd
sudo ln -s /etc/runit/sv/agetty-tty1 /etc/runit/runsvdir/default/
```

## Input devices

The `greeter` user is added to `video` and `input`. tuigreet needs neither --
it reads the VT -- but they are harmless and remove a variable if the seat ever
misbehaves.

```sh
sudo usermod -aG input greeter
```

## When it fails and you cannot see why

Under runit, `sudo sv check greetd` and the output of the service itself; the
run script does `exec 2>&1` so runit captures it. There is no session log to
read any more, because there is no wrapper shell redirecting one.

## What it launches

Whatever you pick from the session list. `mango.desktop` is the only entry here
now that Hyprland is gone.
