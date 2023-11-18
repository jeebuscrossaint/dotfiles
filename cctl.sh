#!/bin/bash
# Script gives a rofi menu to do certain commands

# Config file path
config_file="$HOME/.config/cctl/cctl.config"

# Check if config file exists and contains a password string
if [[ ! -s "$config_file" ]]; then
    # Prompt for password and write it to config file
    read -s -p "Enter a password: " password
    echo "$password" > "$config_file"
    echo "Password set successfully."
fi

# Read the password from config file
password=$(cat "$config_file")

# Prompt for password using Rofi
entered_password=$(rofi -dmenu -password -p "Enter password")

# Check if the entered password is correct
if [[ $entered_password == $password ]]; then
    # Prompt for action using Rofi
    action=$(rofi -dmenu -p "Select action" <<< "Reboot
Shutdown
Logout
Lock")

    # Perform the selected action
    case $action in
        Reboot)
            # Add code to reboot the system
            systemctl reboot
            ;;
        Shutdown)
            # Add code to shutdown the system
            systemctl poweroff
            ;;
        Logout)
            # Add code to logout the user
            wayland-logout
            ;;
        Lock)
            # Add code to lock the screen
            swaylock --config ~/.config/swaylock/swaylockconf
            ;;
        *)
            echo "Invalid action. Exiting..."
            exit 1
            ;;
    esac
    
else
    echo "Incorrect password. Exiting..."
    exit 1
fi

# Rest of your script goes here
# ...
