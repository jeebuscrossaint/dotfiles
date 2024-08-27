#!/usr/bin/env bash

#!/bin/bash

# Check display server type
if [[ $XDG_SESSION_TYPE == "wayland" ]]; then
    # Use fuzzel for Wayland
    action=$(fuzzel -d -R "Select action" <<< "Reboot
Shutdown
Logout
Lock")
elif [[ $XDG_SESSION_TYPE == "x11" ]]; then
    # Use rofi for X11
    action=$(rofi -dmenu -p "Select action" <<< "Reboot
Shutdown
Logout
Lock")
else
    echo "Unknown session type: $XDG_SESSION_TYPE"
    exit 1
fi

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
            pkill Hyprland  
        elif [[ $XDG_SESSION_TYPE == "x11" ]]; then
            pkill herbstluftwm
        fi
        ;;
    Lock)
        if [[ $XDG_SESSION_TYPE == "wayland" ]]; then
            hyprlock  # Replace with your Wayland lock command
        elif [[ $XDG_SESSION_TYPE == "x11" ]]; then
	    xsecurelock
        fi
        ;;
    *)
        echo "Invalid action. Exiting..."
        exit 1
        ;;
esac

