########################################
# Shell init
########################################
#
# fish sources this file in NON-INTERACTIVE shells too, unlike bash. Everything
# a script could need (PATH, EDITOR, locale) is therefore set unconditionally;
# everything only a human uses is behind `status is-interactive`, so scripts in
# this repo do not inherit `ls`=lsd and friends.

set -g fish_greeting

# Logging in on tty1 is logging into mango. `uwsm check may-start` is the guard:
# it fails when this is not a real TTY or a graphical session already exists, so
# tty2-6 stay plain shells, a nested shell inside the session does not recurse,
# and a compositor that dies drops you back to this prompt instead of a loop.
if status is-login; and test (tty) = /dev/tty1
    if command -q uwsm; and uwsm check may-start >/dev/null 2>&1
        exec mango-run
    end
end

########################################
# Environment variables
########################################

set -x EDITOR nvim
# Honoured by xdg-terminal-exec, i3-sensible-terminal and various launchers, so
# "open a terminal" lands on kitty for anything that reads $TERMINAL.
set -x TERMINAL kitty
set -x LANG en_US.UTF-8
set -x LC_ALL en_US.UTF-8
set -x SWAY_UNSUPPORTED_GPU true

# XDG data dirs — /usr/local/share for OpenBSD, flatpak on Linux. Written as one
# literal rather than a `string join` substitution: a command substitution forks
# a shell on every startup, interactive or not.
set -x XDG_DATA_DIRS /usr/local/share:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share

# nnn colors (base16-style: context colors + file type colors)
set -x NNN_COLORS '4231'
set -x NNN_FCOLORS '030304020801060301060207'

fish_add_path ~/.local/bin ~/.cargo/bin

########################################
# Interactive only
########################################

if status is-interactive

    # Coat theme — only re-apply when the theme file has changed. `fish_config theme
    # choose` is ~1.5ms of work, so it stays behind the stamp file.
    if test ~/.config/fish/themes/coat.theme -nt ~/.config/fish/themes/.coat.applied
        fish_config theme choose coat
        touch ~/.config/fish/themes/.coat.applied
    end

    # Aliases. Interactive only: see the header — a script that runs `ls` here would
    # otherwise get lsd's icons and colour.
    alias jit="git"
    alias cl="clear"
    alias 11="ping 1.1.1.1"
    alias xcopy="wl-copy"
    alias ls="lsd"
    alias vi="nvim"
    alias vim="nvim"
    #alias doas="sudo"

    # findheader and colorview live in functions/ so fish autoloads them on first
    # use instead of parsing them into every shell that starts.

    # Keep paru's AUR completion cache fresh (paru's own generator corrupts it, so
    # CompletionInterval is pinned huge in paru.conf). Refresh in the background at
    # most weekly; never blocks the prompt. `path mtime -R` is the builtin age-in-
    # seconds check — the `find -mtime` it replaced forked a process every startup.
    if test -x ~/.local/bin/refresh-paru-completions
        set -l pc ~/.cache/paru/packages.aur
        set -l age (path mtime -R $pc)
        if test -z "$age"; or test $age -gt 604800
            ~/.local/bin/refresh-paru-completions >/dev/null 2>&1 &
            disown
        end
    end
end
