#!/bin/bash
#killall hyprpaper
#killall mpvpaper

WALLPAPER_DIR="$HOME/wallpaper"
WALLPAPER=$(ls $WALLPAPER_DIR | fuzzel -d -R)
killall hyprpaper
export SWWW_TRANSITION=random
swww img "$WALLPAPER_DIR/$WALLPAPER"

