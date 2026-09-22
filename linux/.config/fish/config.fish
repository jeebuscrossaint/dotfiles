set -g fish_greeting

if status is-login; and test (tty) = /dev/tty1
    if command -q uwsm; and uwsm check may-start >/dev/null 2>&1
        exec mango-run
    end
end

set -x EDITOR micro
set -x TERMINAL kitty
set -x LANG en_US.UTF-8
set -x LC_ALL en_US.UTF-8

set -x XDG_DATA_DIRS /usr/local/share:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share

fish_add_path ~/.local/bin ~/.cargo/bin

if status is-interactive

    # Coat theme — only re-apply when the theme file has changed. `fish_config theme
    # choose` is ~1.5ms of work, so it stays behind the stamp file.
    if test ~/.config/fish/themes/coat.theme -nt ~/.config/fish/themes/.coat.applied
        fish_config theme choose coat
        touch ~/.config/fish/themes/.coat.applied
    end

    alias jit="git"
    alias cl="clear"
    alias 11="ping 1.1.1.1"
    alias xcopy="wl-copy"
    alias ls="lsd"
    alias vi="micro"
    alias doas="sudo"

    if test -x ~/.local/bin/refresh-paru-completions
        set -l pc ~/.cache/paru/packages.aur
        set -l age (path mtime -R $pc)
        if test -z "$age"; or test $age -gt 604800
            ~/.local/bin/refresh-paru-completions >/dev/null 2>&1 &
            disown
        end
    end
end
