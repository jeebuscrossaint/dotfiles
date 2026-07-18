########################################
# Interactive shell init
########################################

set -g fish_greeting

# Coat theme — only re-apply when theme file has changed (interactive only)
if status is-interactive
    if test -f ~/.config/fish/themes/coat.theme
        if not test -f ~/.config/fish/themes/.coat.applied; or test ~/.config/fish/themes/coat.theme -nt ~/.config/fish/themes/.coat.applied
            fish_config theme choose coat
            touch ~/.config/fish/themes/.coat.applied
        end
    end
end

set -x EDITOR helix
set -x LANG en_US.UTF-8
set -x LC_ALL en_US.UTF-8
set -x SWAY_UNSUPPORTED_GPU true

########################################
# Environment variables
########################################

# XDG data dirs — /usr/local/share for OpenBSD, flatpak on Linux
set -x XDG_DATA_DIRS (string join : \
    /usr/local/share \
    /usr/share \
    /var/lib/flatpak/exports/share \
    $HOME/.local/share/flatpak/exports/share)

fish_add_path ~/.local/bin ~/.cargo/bin

# nnn colors (base16-style: context colors + file type colors)
set -x NNN_COLORS '4231'
set -x NNN_FCOLORS '030304020801060301060207'

########################################
# Aliases
########################################

alias jit="git"
alias cl="clear"
alias 11="ping 1.1.1.1"
alias xcopy="wl-copy"
alias ls="lsd"
#alias doas="sudo"

########################################
# Functions
########################################

# Find C/C++ headers
function findheader
    find /usr/include /usr/local/include -name "$argv[1]" 2>/dev/null
end

# View hex colors in terminal
function colorview --argument hex
    set hex (string replace -r '^#?' '' -- $hex)
    set r (string sub -s 1 -l 2 $hex)
    set g (string sub -s 3 -l 2 $hex)
    set b (string sub -s 5 -l 2 $hex)
    printf "\033[48;2;%d;%d;%dm     \033[0m %s\n" \
        (printf "%d" "0x$r") \
        (printf "%d" "0x$g") \
        (printf "%d" "0x$b") \
        $hex
end

########################################
# Startup
########################################

if status is-interactive
    # Keep paru's AUR completion cache fresh (paru's own generator corrupts it,
    # so CompletionInterval is pinned huge in paru.conf). Refresh in the
    # background at most weekly; never blocks the prompt.
    if test -x ~/.local/bin/refresh-paru-completions
        set -l pc ~/.cache/paru/packages.aur
        set -l stale (find $pc -mtime +7 2>/dev/null)
        if not test -f $pc; or test -n "$stale"
            ~/.local/bin/refresh-paru-completions >/dev/null 2>&1 &
            disown
        end
    end

    if command -q fastfetch
        fastfetch
    end
end
