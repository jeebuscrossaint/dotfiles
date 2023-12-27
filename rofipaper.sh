#!/bin/bash
#killall hyprpaper
#killall mpvpaper
#killall swww init
#killall swww-daemon
WALLPAPER_DIR="$HOME/wallpaper"
WALLPAPER=$(ls $WALLPAPER_DIR | rofi -dmenu)
export SWWW_TRANSITION=random
swww img "$WALLPAPER_DIR/$WALLPAPER"

