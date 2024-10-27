#!/bin/bash

# Directory containing your wallpapers (including GIFs and videos)
WALLPAPER_DIR="$HOME/wallpapers"

# Function to set static wallpaper using feh
set_static_wallpaper() {
    feh --bg-fill "$1"
}

# Function to set animated wallpaper using xwinwrap and mpv
set_animated_wallpaper() {
    # Kill any existing xwinwrap instances
    killall xwinwrap

    # Get screen resolution
    RESOLUTION=$(xrandr | grep '*' | awk '{print $1}')

    # Start new xwinwrap instance
    xwinwrap -g $RESOLUTION -ov -ni -s -nf -- mpv -wid WID --loop --no-audio --no-osc --no-osd-bar --panscan=1.0 "$1" &
}

# Get list of wallpapers
wallpapers=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.gif" -o -name "*.mp4" \))

# Use Rofi to select wallpaper
selected=$(echo "$wallpapers" | sed "s|$WALLPAPER_DIR/||g" | rofi -dmenu -i -p "Select Wallpaper")

# Set the selected wallpaper
if [ -n "$selected" ]; then
    full_path="$WALLPAPER_DIR/$selected"
    extension="${selected##*.}"
    
    case "$extension" in
        gif|mp4)
            set_animated_wallpaper "$full_path"
            ;;
        *)
            set_static_wallpaper "$full_path"
            ;;
    esac
fi
