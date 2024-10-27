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
    export SWWW_TRANSITION=simple # should be random
    export SWWW_TRANSITION_FPS=120
    export SWWW_TRANSITION_DURATION=5
    swww img "$1"
}

# Get list of wallpapers
wallpapers=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.webp" -o -name "*.gif" -o -name "*.mp4" \))

# Use Rofi to select wallpaper
selected=$(echo "$wallpapers" | sed "s|$WALLPAPER_DIR/||g" | rofi -dmenu -i -p "Select Wallpaper")

# Set the selected wallpaper
if [ -n "$selected" ]; then
    full_path="$WALLPAPER_DIR/$selected"
    extension="${selected##*.}"
    
    if [[ $XDG_SESSION_TYPE == "wayland" ]]; then
        set_wallpaper_wayland "$full_path"
    elif [[ $XDG_SESSION_TYPE == "x11" ]]; then
        case "$extension" in
            gif|mp4)
                set_animated_wallpaper_x11 "$full_path"
                ;;
            *)
                set_static_wallpaper_x11 "$full_path"
                ;;
        esac
    else
        echo "Unknown session type: $XDG_SESSION_TYPE"
        exit 1
    fi
fi
