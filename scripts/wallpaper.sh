#!/bin/bash

WALLPAPER_DIR="$HOME/dotfiles/wallpapers"

# Function to set static wallpaper using feh (X11)
set_static_wallpaper_x11() {
    feh --bg-fill "$1"
}

# Function to set animated wallpaper using xwinwrap and mpv (X11)
set_animated_wallpaper_x11() {
    killall xwinwrap
    RESOLUTION=$(xrandr | grep '*' | awk '{print $1}')
    xwinwrap -g $RESOLUTION -ov -ni -s -nf -- mpv -wid WID --loop --no-audio --no-osc --no-osd-bar --panscan=1.0 "$1" &
}

# Function to set wallpaper for Wayland
set_wallpaper_wayland() {
    swww-daemon
    export SWWW_TRANSITION=fade # should be random
    export SWWW_TRANSITION_FPS=120
    export SWWW_TRANSITION_DURATION=0
    swww img "$1"

}

# Get list of wallpapers
wallpapers=$(ls $WALLPAPER_DIR)
# Use Rofi to select wallpaper
selected=$(echo "$wallpapers" | sed "s|$WALLPAPER_DIR/||g" | rofi -dmenu -i -p "Select Wallpaper")

# Set the selected wallpaper
if [ -n "$selected" ]; then
    full_path="$WALLPAPER_DIR/$selected"
    extension="${selected##*.}"

	# run pywal and pywal fox
	wal -i "$full_path" -n
	pywalfox update
	killall -SIGUSR2 waybar
	pkill dunst
	ln -sf "${HOME}/.cache/wal/dunstrc" "${HOME}/.config/dunst/dunstrc"
	dunst &
	i3-msg reload
	walcord
    
    if [[ $XDG_SESSION_TYPE == "wayland" ]]; then
        set_wallpaper_wayland "$full_path"
    elif [[ $XDG_SESSION_TYPE == "x11" ]]; then
        case "$extension" in
            gif|mp4)
                set_animated_wallpaper_x11 "$full_path"
                ;;
            *)
                set_static_wallpaper_x11 "$full_path"
		pkill lemon.sh
		~/.config/lemonbar/lemon.sh
                ;;
        esac
    else
        echo "Unknown session type: $XDG_SESSION_TYPE"
        exit 1
    fi
fi

