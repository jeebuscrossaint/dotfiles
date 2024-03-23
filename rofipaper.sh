#!/bin/bash
WALLPAPER_DIR="$HOME/wallpapers/wallpaper"
export SWWW_TRANSITION=random
export SWWW_TRANSITION_FPS=120
export SWWW_TRANSITION_DURATION=5

WALLPAPER=$(ls $WALLPAPER_DIR | rofi -dmenu)
swww img "$WALLPAPER_DIR/$WALLPAPER"
