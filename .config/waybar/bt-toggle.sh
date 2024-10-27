#!/bin/bash

# Get the current power status
POWER_STATUS=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')

# Toggle the power based on the current status
if [ "$POWER_STATUS" = "yes" ]; then
  echo "Turning Bluetooth off..."
  echo -e "power off\nexit" | bluetoothctl
else
  echo "Turning Bluetooth on..."
  echo -e "power on\nexit" | bluetoothctl
fi
