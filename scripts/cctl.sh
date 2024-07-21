#!/bin/bash
# Script gives a rofi menu to do certain commands


# Check if the entered password is correct
if [[ $entered_password == $password ]]; then
    # Prompt for action using Rofi
    action=$(fuzzel -d -R "Select action" <<< "Reboot
Shutdown
Logout
Lock")

    # Perform the selected action
    case $action in
        Reboot)
            # Add code to reboot the system
            loginctl reboot
            ;;
        Shutdown)
            # Add code to shutdown the system
            loginctl poweroff
            ;;
        Logout)
            # Add code to logout the user
            pkill Hyprland
            ;;
        Lock)
            # Add code to lock the screen
            hyprlock
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
