ram=$(free -h | awk '/^Mem/ {print $3}')

echo " Ram: $ram "
