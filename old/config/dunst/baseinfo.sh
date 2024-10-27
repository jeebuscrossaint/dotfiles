#!/bin/bash

# Battery Info
battery_info=$(acpi -b | awk '{print $4, $3, $5}')
battery_state=$(echo "$battery_info" | awk '{print $2}')
battery_percent=$(echo "$battery_info" | awk '{print $1}')

# RAM and Swap Usage
ram_info=$(free -h | awk '/^Mem/ {print $3}')
swap_info=$(free -h | awk '/^Swap/ {print $3}')

# Brightness
brightness_raw=$(brightnessctl | grep "Current brightness" | awk '{print $3}')
brightness_percent=$((brightness_raw * 100 / 96000))

# Volume Info
volume_info=$(amixer -D pulse sget Master | grep -oE "[0-9]+%" | head -n 1)
volume_muted=$(amixer -D pulse sget Master | grep -oE "\[off\]" | head -n 1)

# Package Count
package_count=$(paru -Q | wc -l)

# CPU Temperature
cpu_temp=$(acpi -t | awk '{print $4}')

# Uptime
uptime=$(uptime -p)

# Storage Usage
storage_info=$(df -h / | awk 'NR==2 {print $3"/"$2" ("$5")"}')

# Current Time
current_time=$(date "+%Y-%m-%d %H:%M:%S")

# Network Information
network_info=$(iwgetid -r)

# Notification
dunstify "Current Time: $current_time
Battery: $battery_percent $battery_state
RAM Usage: $ram_info, Swap Usage: $swap_info
Brightness: $brightness_percent%
Volume: $volume_info $volume_muted
Packages Installed: $package_count
CPU Temperature: $cpu_temp
Uptime: $uptime
Storage Usage: $storage_info
Network: $network_info"
