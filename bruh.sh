#!/usr/bin/env bash

# NixOS System Info Display Script
# Displays: CPU%, Temp°F, Memory%, Swap%, Load avg, Uptime, Battery info, 
# Volume%, Date, WiFi info

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Function to get CPU percentage
get_cpu_percent() {
    # Get CPU usage from /proc/stat
    cpu_usage=$(awk '/^cpu / {usage=($2+$4)*100/($2+$3+$4+$5)} END {printf "%.1f", usage}' /proc/stat)
    echo "${cpu_usage}%"
}

# Function to get CPU temperature in Fahrenheit
get_cpu_temp() {
    # Try multiple temperature sources
    temp_celsius=""
    
    # Try thermal zones first
    if [[ -d /sys/class/thermal/thermal_zone0 ]]; then
        temp_raw=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo "")
        if [[ -n "$temp_raw" ]]; then
            temp_celsius=$((temp_raw / 1000))
        fi
    fi
    
    # Try hwmon if thermal zones didn't work
    if [[ -z "$temp_celsius" ]] && [[ -d /sys/class/hwmon ]]; then
        for hwmon in /sys/class/hwmon/hwmon*/temp*_input; do
            if [[ -r "$hwmon" ]]; then
                temp_raw=$(cat "$hwmon" 2>/dev/null || echo "")
                if [[ -n "$temp_raw" ]] && [[ "$temp_raw" -gt 10000 ]]; then
                    temp_celsius=$((temp_raw / 1000))
                    break
                fi
            fi
        done
    fi
    
    # Convert to Fahrenheit
    if [[ -n "$temp_celsius" ]]; then
        temp_fahrenheit=$(echo "$temp_celsius * 9 / 5 + 32" | bc -l | cut -d. -f1)
        echo "${temp_fahrenheit}°F"
    else
        echo "N/A"
    fi
}

# Function to get memory percentage
get_memory_percent() {
    mem_info=$(free | grep '^Mem:')
    total=$(echo $mem_info | awk '{print $2}')
    used=$(echo $mem_info | awk '{print $3}')
    percent=$(echo "scale=1; $used * 100 / $total" | bc)
    echo "${percent}%"
}

# Function to get swap percentage
get_swap_percent() {
    swap_info=$(free | grep '^Swap:')
    total=$(echo $swap_info | awk '{print $2}')
    used=$(echo $swap_info | awk '{print $3}')
    
    if [[ "$total" -eq 0 ]]; then
        echo "N/A"
    else
        percent=$(echo "scale=1; $used * 100 / $total" | bc)
        echo "${percent}%"
    fi
}

# Function to get load averages
get_load_avg() {
    load=$(cat /proc/loadavg | awk '{print $1, $2, $3}')
    echo "$load"
}

# Function to get uptime
get_uptime() {
    uptime_seconds=$(cat /proc/uptime | cut -d' ' -f1 | cut -d. -f1)
    days=$((uptime_seconds / 86400))
    hours=$(((uptime_seconds % 86400) / 3600))
    minutes=$(((uptime_seconds % 3600) / 60))
    
    if [[ $days -gt 0 ]]; then
        echo "${days}d ${hours}h ${minutes}m"
    elif [[ $hours -gt 0 ]]; then
        echo "${hours}h ${minutes}m"
    else
        echo "${minutes}m"
    fi
}

# Function to get battery info
get_battery_info() {
    battery_dir="/sys/class/power_supply"
    battery_info=""
    
    # Find battery
    for bat in "$battery_dir"/BAT*; do
        if [[ -d "$bat" ]]; then
            capacity=$(cat "$bat/capacity" 2>/dev/null || echo "N/A")
            status=$(cat "$bat/status" 2>/dev/null || echo "Unknown")
            
            # Try to get health percentage
            health="N/A"
            if [[ -f "$bat/charge_full" ]] && [[ -f "$bat/charge_full_design" ]]; then
                full=$(cat "$bat/charge_full")
                design=$(cat "$bat/charge_full_design")
                health=$(echo "scale=1; $full * 100 / $design" | bc)
                health="${health}%"
            elif [[ -f "$bat/energy_full" ]] && [[ -f "$bat/energy_full_design" ]]; then
                full=$(cat "$bat/energy_full")
                design=$(cat "$bat/energy_full_design")
                health=$(echo "scale=1; $full * 100 / $design" | bc)
                health="${health}%"
            fi
            
            battery_info="${capacity}% ${status} (Health: ${health})"
            break
        fi
    done
    
    if [[ -z "$battery_info" ]]; then
        echo "N/A"
    else
        echo "$battery_info"
    fi
}

# Function to get volume percentage
get_volume_percent() {
    # Try PipeWire first
    if command -v wpctl &> /dev/null; then
        volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{print int($2*100)}')
        if [[ -n "$volume" ]]; then
            echo "${volume}%"
            return
        fi
    fi
    
    # Fallback to ALSA
    if command -v amixer &> /dev/null; then
        volume=$(amixer get Master 2>/dev/null | grep -o '[0-9]*%' | head -1)
        if [[ -n "$volume" ]]; then
            echo "$volume"
            return
        fi
    fi
    
    echo "N/A"
}

# Function to get current date/time
get_datetime() {
    date '+%Y-%m-%d %H:%M:%S %Z'
}

# Function to get WiFi info (using dbus - fast and reliable)
get_wifi_info() {
    # Try to get WiFi info via NetworkManager dbus (fastest method)
    if command -v dbus-send &> /dev/null; then
        # Find wireless devices and get active connection
        local devices
        devices=$(dbus-send --system --print-reply --dest=org.freedesktop.NetworkManager /org/freedesktop/NetworkManager org.freedesktop.NetworkManager.GetDevices 2>/dev/null | grep -o "object path \"[^\"]*\"" | sed 's/object path "//' | sed 's/"//')
        
        for device in $devices; do
            # Check if this device is wireless and has an active access point
            local ap_path
            ap_path=$(dbus-send --system --print-reply --dest=org.freedesktop.NetworkManager "$device" org.freedesktop.DBus.Properties.Get string:org.freedesktop.NetworkManager.Device.Wireless string:ActiveAccessPoint 2>/dev/null | grep "object path" | grep -v '""' | sed 's/.*object path "//' | sed 's/".*//')
            
            if [[ -n "$ap_path" && "$ap_path" != "/" ]]; then
                # Get SSID from the active access point
                local ssid
                ssid=$(dbus-send --system --print-reply --dest=org.freedesktop.NetworkManager "$ap_path" org.freedesktop.DBus.Properties.Get string:org.freedesktop.NetworkManager.AccessPoint string:Ssid 2>/dev/null | grep "array of bytes" | sed 's/.*array of bytes "//' | sed 's/".*//')
                
                if [[ -n "$ssid" ]]; then
                    echo "$ssid"
                    return
                fi
            fi
        done
    fi
    
    # Fallback: just check if we have a wireless interface that's up
    local iface
    iface=$(ip -o -4 route show to default | awk '{print $5}' | grep '^wl' || true)
    
    if [[ -n "$iface" ]] && [[ -e "/sys/class/net/$iface/wireless" ]]; then
        if ip link show "$iface" 2>/dev/null | grep -q "state UP"; then
            echo "Connected"
        else
            echo "Not Connected"
        fi
    else
        echo "Not Connected"
    fi
}


# Main display function for terminal
display_system_info() {
    echo -e "${WHITE}=== System Information ===${NC}"
    echo ""
    
    echo -e "${CYAN}CPU Usage:${NC}        $(get_cpu_percent)"
    echo -e "${RED}Temperature:${NC}      $(get_cpu_temp)"
    echo -e "${GREEN}Memory:${NC}          $(get_memory_percent)"
    echo -e "${YELLOW}Swap:${NC}            $(get_swap_percent)"
    echo -e "${BLUE}Load Average:${NC}     $(get_load_avg)"
    echo -e "${MAGENTA}Uptime:${NC}          $(get_uptime)"
    echo -e "${GREEN}Battery:${NC}         $(get_battery_info)"
    echo -e "${CYAN}Volume:${NC}          $(get_volume_percent)"
    echo -e "${WHITE}Date/Time:${NC}       $(get_datetime)"
    echo -e "${BLUE}WiFi:${NC}            $(get_wifi_info)"
}

# Function to create notification text (plain text, no colors)
create_notification_text() {
    cat << EOF
 CPU: $(get_cpu_percent)
 Temp: $(get_cpu_temp)
 RAM: $(get_memory_percent)
 Swap: $(get_swap_percent)
 Load: $(get_load_avg)
 Uptime: $(get_uptime)
 Battery: $(get_battery_info)
 Volume: $(get_volume_percent)
 Time: $(get_datetime)
 WiFi: $(get_wifi_info)
EOF
}

# Function to send a notification (works with Dunst)
send_notification() {
    local message
    message=$(create_notification_text)
    
    # Send notification using notify-send (works with Dunst)
    notify-send \
        --app-name="System Monitor" \
        --icon="dialog-information" \
        --category="system" \
        --urgency="normal" \
        --expire-time=10000 \
        "System Info" \
        "$message"
}

# Parse command line arguments
case "${1:-}" in
    "--watch")
        while true; do
            clear
            display_system_info
            sleep 2
        done
        ;;
    "--notify"|"--dunst")
        send_notification
        ;;
    "--help"|"-h")
        echo "System Information Script"
        echo "Usage:"
        echo "  $0           - Display in terminal"
        echo "  $0 --watch   - Display in terminal with auto-refresh"
        echo "  $0 --notify  - Send notification (works with Dunst)"
        echo "  $0 --dunst   - Send notification (same as --notify)"
        echo "  $0 --help    - Show this help"
        ;;
    *)
        display_system_info
        ;;
esac
