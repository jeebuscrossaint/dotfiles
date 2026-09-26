#!/bin/sh
# Fresh Arch box -> my desktop.
#   curl -LO apatel.co/dotfiles/rice.sh && sh rice.sh
#
# Plain sh because a fresh install has no fish. Everything past cloning the repo
# is install.fish's job; this only gets it running.
set -eu

repo=https://github.com/jeebuscrossaint/dotfiles.git
dir=$HOME/dotfiles

die() { printf '\033[1;31m ✗\033[0m %s\n' "$*" >&2; exit 1; }
step() { printf '\033[1;36m::\033[0m %s\n' "$*"; }

command -v pacman >/dev/null || die "not Arch (no pacman)"
# makepkg refuses root, and paru is built with it.
[ "$(id -u)" -ne 0 ] || die "run as your normal user (with sudo), not root"
command -v sudo >/dev/null || die "sudo is missing: as root, pacman -S sudo and add yourself to wheel"

step "Updating the system and installing git + fish"
sudo pacman -Syu --needed --noconfirm git fish

if [ -d "$dir/.git" ]; then
    step "$dir exists, pulling"
    git -C "$dir" pull --ff-only
else
    step "Cloning dotfiles into $dir"
    git clone "$repo" "$dir"
fi

if [ "$(getent passwd "$USER" | cut -d: -f7)" != /usr/bin/fish ]; then
    step "Making fish the login shell"
    chsh -s /usr/bin/fish
fi

step "Handing off to install.fish"
exec fish "$dir/install.fish" --install-deps --backup
