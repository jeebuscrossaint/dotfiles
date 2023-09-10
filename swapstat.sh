swap=$(free -h | awk '/^Swap/ {print $3}')

echo " Swap: $swap "
