# wlock

wlock is a itsy-bitsy sessionlocker for Wayland compositors that support
the `ext-session-lock-v1` protocol; an effective port of slock to Wayland, merging
the alternate color patch to give a sense of feedback.

Excerpt from the protocol specifying the behavior:
> The client is responsible for performing authentication and informing the
> compositor when the session should be unlocked. If the client dies while
> the session is locked the session remains locked, possibly permanently
> depending on compositor policy.

## Building

To build wlock first ensure that you have the following dependencies:

* pkg-config
* wayland
* wayland-protocols
* xkbcommon

After installing the dependencies, you may build and install wlock:
```
make
make install
```

## Usage

Run `wlock`, to get out of it, enter your password.

See the wlock usage (`wlock -h`) for more details.

See [swayidle](https://github.com/swaywm/swayidle) or 
[widle](https://codeberg.org/sewn/widle) to use wlock
as a screen locker for a Wayland desktop.

## Comparison

* [waylock](https://codeberg.org/ifreund/waylock): waylock and wlock
  are very similar functionality wise, with the only change being
  security (PAM) and codebase (Zig), being nicer to work with, as it
  comes from the author of River.

## Credits

- [swaylock](https://github.com/swaywm/swaylock)
- [waylock](https://codeberg.org/ifreund/waylock)
