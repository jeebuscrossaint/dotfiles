# if status is-interactive
# Commands to run in interactive sessions can go here
# end
########################################
# Interactive shell init
########################################

# Disable Fish greeting
set -g fish_greeting

# Starship prompt
starship init fish | source

########################################
# Environment variables
########################################

# Flatpak paths
set -x XDG_DATA_DIRS $XDG_DATA_DIRS \
    /var/lib/flatpak/exports/share \
    $HOME/.local/share/flatpak/exports/share

# Qt / graphics
set -x QT_QPA_PLATFORMTHEME qt5ct
set -x GSK_RENDERER ngl

# Nix compatibility
set -x NIXPKGS_ALLOW_UNFREE 1

########################################
# Startup commands
########################################

# Keyboard backlight (ignore errors)
brightnessctl -d asus::kbd_backlight s 3 >/dev/null 2>&1 &

# Direnv
# direnv hook fish | source

########################################
# Aliases
########################################

alias jit="git"
alias cl="clear"
alias 11="ping 1.1.1.1"
alias xcopy="xclip -sel clip"

alias display-update="xrandr \
  --output eDP-1 --mode 2560x1600 --rate 240.00 --primary \
  --output HDMI-1-0 --mode 1920x1080 --rate 60.00 --right-of eDP-1"

########################################
# Functions
########################################

# Find C/C++ headers
function findheader
    find /usr/include /usr/local/include -name "$argv[1]" 2>/dev/null
end

# View hex colors in terminal
function colorview --argument hex
    # Strip leading #
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
