#!/bin/sh
# Bootstrap for install.fish — the real installer.  Kept so `./install.sh` and
# any old muscle memory still work on a machine where fish isn't installed yet.

set -e

if ! command -v fish >/dev/null 2>&1; then
    echo "fish is not installed, and the installer is written in fish." >&2
    echo "  pacman -S fish   ·   apt install fish   ·   pkg_add fish" >&2
    echo "Or just: stow -d \"$(cd "$(dirname "$0")" && pwd)\" -t \"$HOME\" linux" >&2
    exit 1
fi

exec fish "$(cd "$(dirname "$0")" && pwd)/install.fish" "$@"
