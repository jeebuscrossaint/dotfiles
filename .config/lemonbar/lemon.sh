#!/bin/bash

# Load Pywal colors
source ~/.cache/wal/colors.sh

# Get active window title
get_window_title() {
    xprop -id "$(xprop -root _NET_ACTIVE_WINDOW | awk -F' ' '{print $5}')" \
        _NET_WM_NAME | awk -F'"' '{print $2}'
}

# Battery info
get_battery() {
    if [ -d "/sys/class/power_supply/BAT0" ]; then
        capacity=$(cat /sys/class/power_supply/BAT0/capacity)
        status=$(cat /sys/class/power_supply/BAT0/status)
        if [ "$status" == "Charging" ]; then
            echo "⚡ $capacity%"
        else
            echo "🔋 $capacity%"
        fi
    else
        echo "No Battery"
    fi
}

# CPU Temperature
get_cpu_temp() {
    temp=$(sensors | grep -m 1 'Core 0:' | awk '{print $3}' | tr -d '+°C')
    if [ -z "$temp" ]; then
        temp_raw=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -n 1)
        if [ -n "$temp_raw" ]; then
            temp=$(awk "BEGIN {print $temp_raw / 1000}")
        fi
    fi

    if [ -z "$temp" ]; then
        echo "Temp: N/A"
    else
        printf "Temp: %.1f°F\n" "$(bc <<< "($temp * 9/5) + 32")"
    fi
}

# Memory usage with Swap
get_memory() {
    mem_used=$(free -m | awk '/^Mem:/ {print $3}')
    mem_total=$(free -m | awk '/^Mem:/ {print $2}')
    swap_used=$(free -m | awk '/^Swap:/ {print $3}')
    swap_total=$(free -m | awk '/^Swap:/ {print $2}')
    echo "Mem: $mem_used/$mem_total MB | Swap: $swap_used/$swap_total MB"
}

# CPU Usage
get_cpu_usage() {
    read cpu a b c prev_idle rest < /proc/stat
    prev_total=$((a + b + c + prev_idle))
    sleep 0.1
    read cpu a b c idle rest < /proc/stat
    total=$((a + b + c + idle))
    cpu=$((100 * ((total - prev_total) - (idle - prev_idle)) / (total - prev_total)))
    echo "CPU: $cpu%"
}

# Disk I/O
get_disk_io() {
    io=$(iostat -d 1 1 | awk '/^Device:/ {getline; printf "Disk: Read %.1f KB/s | Write %.1f KB/s", $3, $4}')
    echo "$io"
}

# Network traffic
get_network_traffic() {
    iface=$(ip -o link show | awk -F': ' '$2 ~ /^[ew]/ {print $2}' | head -n 1)
    if [ -z "$iface" ]; then
        echo "Net: N/A"
    else
        rx_file="/sys/class/net/$iface/statistics/rx_bytes"
        tx_file="/sys/class/net/$iface/statistics/tx_bytes"

        if [ ! -f "$rx_file" ] || [ ! -f "$tx_file" ]; then
            echo "Net: N/A"
        else
            rx=$(cat "$rx_file")
            tx=$(cat "$tx_file")
            sleep 0.1
            rx_new=$(cat "$rx_file")
            tx_new=$(cat "$tx_file")
            rx_rate=$(( (rx_new - rx) / 1024 ))
            tx_rate=$(( (tx_new - tx) / 1024 ))
            echo "Net: ↓ ${rx_rate}KB ↑ ${tx_rate}KB"
        fi
    fi
}

# Bluetooth status
get_bluetooth() {
    if bluetoothctl show | grep -q "Powered: yes"; then
        device=$(bluetoothctl info | grep "Name" | awk -F': ' '{print $2}')
        [ -z "$device" ] && echo "BLE: On" || echo "BLE: $device"
    else
        echo "BLE: Off"
    fi
}

# Volume and mic volume
get_volume() {
    vol=$(amixer get Master | grep -o "[0-9]*%" | head -n 1)
    mic=$(amixer get Capture | grep -o "[0-9]*%" | head -n 1)
    echo "Vol: $vol Mic: $mic"
}

# Backlight percentage
get_backlight() {
    max_brightness=$(cat /sys/class/backlight/*/max_brightness)
    current_brightness=$(cat /sys/class/backlight/*/brightness)
    percentage=$(( 100 * current_brightness / max_brightness ))
    echo "Backlight: $percentage%"
}

# Workspaces
get_workspaces() {
    ws_list=$(xprop -root _NET_DESKTOP_NAMES | awk -F'"' '{for(i=2;i<=NF;i+=2)printf "%s ", $i}')
    ws_active=$(xprop -root _NET_CURRENT_DESKTOP | awk '{print $3}')
    echo "$ws_list" | awk -v active="$ws_active" '{for(i=1;i<=NF;i++)if(i-1==active)printf "[%s] ", $i; else printf "%s ", $i}'
}

# Main loop
while :; do
    date_time=$(date '+%A %H:%M:%S %Y-%m-%d')
    window_title=$(get_window_title)
    workspaces=$(get_workspaces)
    battery=$(get_battery)
    keyboard_state=$(xset q | grep "Caps Lock" | awk '{print "Caps:" $4 " Num:" $8}')
    backlight=$(get_backlight)
    cpu_temp=$(get_cpu_temp)
    memory=$(get_memory)
    cpu_usage=$(get_cpu_usage)
    net_traffic=$(get_network_traffic)
    bluetooth=$(get_bluetooth)
    volume=$(get_volume)

    echo -e "  %{l}$workspaces| $date_time %{c}$window_title %{r}$volume | $bluetooth | $cpu_usage | $memory | $cpu_temp | $backlight | $keyboard_state |$battery "
done | lemonbar -g 1920x30 -B "$color0" -F "$color8" &
