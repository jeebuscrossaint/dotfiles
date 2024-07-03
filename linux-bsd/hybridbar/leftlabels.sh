cap=$(cat /sys/class/power_supply/BAT0/capacity)
stat=$(cat /sys/class/power_supply/BAT0/status)
up=$(uptime -p)
pkg=$(paru -Q | wc -l)

echo "$cap% $stat -- $up -- Packages: $pkg "


