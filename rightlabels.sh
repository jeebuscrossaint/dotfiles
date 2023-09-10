network=$(iwgetid -r)
vol=$(volumectl)
temper=$(acpi -t | awk '{print $4}')

echo " Network: $network -- $vol -- $temper°C "

