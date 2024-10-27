#!/usr/bin/env bash

# Use rofi to display the menu
action=$(echo -e "Reboot\nShutdown\nLogout\nLock" | rofi -dmenu -p "Select action")

# Perform the selected action
case $action in
    Reboot)
        reboot
        ;;
    Shutdown)
        shutdown
        ;;
    Logout)
        if [[ $XDG_SESSION_TYPE == "wayland" ]]; then
            pkill Hyprland && pkill niri 
        elif [[ $XDG_SESSION_TYPE == "x11" ]]; then
            pkill X
        else
            echo "Unknown session type: $XDG_SESSION_TYPE"
            exit 1
        fi
        ;;
    Lock)
        if [[ $XDG_SESSION_TYPE == "wayland" ]]; then
            swaylock --config ~/.config/swaylock/swaylockconf
        elif [[ $XDG_SESSION_TYPE == "x11" ]]; then
            xsecurelock
        else
            echo "Unknown session type: $XDG_SESSION_TYPE"
            exit 1
        fi
        ;;
    *)
        echo "Invalid action. Exiting..."
        exit 1
        ;;
esac
