# widle

widle is a tiny application that runs a command upon becoming idle utilizing
the `ext-idle-notify-v1` protocol.

## Building

To build widle first ensure that you have the following dependencies:

* pkg-config
* wayland
* wayland-protocols

Afterwards, run:
```
make
make install
```

## Usage

See the man page.

## Comparison

There are other idle management daemons for wayland compositors that can compare
with widle, and can have behavioural changes or codebase differences:

* [swayidle](https://github.com/swaywm/swayidle):
  Significantly more control compared to widle, but has a bigger
  (~900 LOC vs ~200 LOC) codebase, and can replicate widles behavior
  with `swayidle 'timeout 360 wlock'`.
* [wayidle](https://sr.ht/~whynothugo/wayidle):
  Only runs the command once instead of looping, and is written in Rust.

Swayidle is reccomended in more practical or flexible idle management such as
performing commands on specific timeouts, optionally waiting on command finish,
and having specific set actions on timeout idle/resume.

## Credits

* [kennylevinsen](https://kl.wtf/)
* [ifreund](https://isaacfreund.com/)
