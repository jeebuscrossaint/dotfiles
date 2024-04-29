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
