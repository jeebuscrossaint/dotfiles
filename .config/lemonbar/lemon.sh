#!/bin/bash
BAR_FIFO=/tmp/bar-fifo

# Delete in case it already exists
rm $BAR_FIFO

mkfifo $BAR_FIFO

## Write into it
# Date
while true; do
    date=`date +"%A %d %B"`
    time=`date +"%R"`
    echo 'D' ${date}, ${time}
    sleep 59
done > $BAR_FIFO &

# Battery
while true; do
    echo 'B' " $(< /sys/class/power_supply/BAT0/capacity)%"
    sleep 30
done > $BAR_FIFO &

# Network
while true; do
    name=$(iwgetid -r)
    if [ $? -eq 0 ]; then
        echo 'N' "直 $name"
    else
        echo 'N' "%{F$color01}睊%{F-}"
    fi
    sleep 10
done > $BAR_FIFO &

# Desktops
while true; do
    total=$(xdotool get_num_desktops)
    current=$(xdotool get_desktop)
    desktops=""

    for i in $(seq 0 $(($total - 1))); do
        if [ $i == $current ]; then
            desktops+=" ■"
        else
            desktops+=" □"
        fi
    done

    echo 'W' $desktops
    sleep 0.1
done > $BAR_FIFO &

# Constantly read it, processing each line
while read -r line < $BAR_FIFO; do
    case $line in
        # Date
        D*)
            curr_date="${line#?}";;

        # Network
        N*)
            net="${line#?}";;

        # Desktops
        W*)
            wm="${line#?}";;

        # Battery
        B*)
            bat="${line#?}";;
        esac
        printf "%s\n" "%{l}${wm}%{c}${curr_date}%{r}${net}${bat}"
done | lemonbar
