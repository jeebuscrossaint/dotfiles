set -g fish_greeting

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
    # bash's `!!`: expands to the previous command as you type it, so `sudo !!`
    # works and shows what it will run before Enter.
    function __last_history_item
        echo $history[1]
    end
    abbr -a !! --position anywhere --function __last_history_item

    # coat's fonts sit in a second rc.xml that labwc only merges with -m.
    function labwc --wraps labwc
        XDG_CONFIG_DIRS=$HOME/.local/share/coat/labwc:/etc/xdg command labwc -m $argv
    end

    # --session sets XDG_CURRENT_DESKTOP=niri and hands it to dbus/systemd; without
    # it the portal finds no backend and apps lose dark mode.
    function niri --wraps niri
        command niri --session $argv
    end
end
