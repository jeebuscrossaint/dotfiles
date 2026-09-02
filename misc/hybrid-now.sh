#!/bin/sh
# hybrid-now.sh — put the machine back in Hybrid so the dGPU can reach D3cold.
#
#   sudo sh misc/hybrid-now.sh && sudo reboot
#
# Two changes, both needed. The mux alone puts eDP back on Intel but leaves the
# 4070 pinned at D0, because nvidia_drm holds the card up merely by being
# loaded (0ms of suspend across a 90s idle sample with it, suspended within 4s
# without -- measured in nvidia-rtd3.conf). The blacklist alone does nothing
# while the panel is still wired to the dGPU in Discrete.
#
# Reversible: comment the blacklist back out and write 0 to the mux.

set -e

[ "$(id -u)" = 0 ] || { echo "hybrid-now: run me as root" >&2; exit 1; }

ARMOURY=/sys/class/firmware-attributes/asus-armoury/attributes/gpu_mux_mode/current_value
LEGACY=/sys/devices/platform/asus-nb-wmi/gpu_mux_mode
CONF=/etc/modprobe.d/nvidia-rtd3.conf

if [ -e "$ARMOURY" ]; then MUX=$ARMOURY; else MUX=$LEGACY; fi
[ -e "$MUX" ] || { echo "hybrid-now: no gpu_mux_mode interface found" >&2; exit 1; }

echo "mux before: $(cat "$MUX")   (0=Discrete, 1=Hybrid)"

# 1. eDP back onto the Intel iGPU. Takes effect at the next POST.
echo 1 >"$MUX"

# 2. Let go of the card so RTD3 can actually park it.
if grep -q '^#blacklist nvidia_drm' "$CONF" 2>/dev/null; then
	sed -i 's/^#blacklist nvidia_drm/blacklist nvidia_drm/' "$CONF"
	echo "uncommented: blacklist nvidia_drm in $CONF"
elif grep -q '^blacklist nvidia_drm' "$CONF" 2>/dev/null; then
	echo "already set: blacklist nvidia_drm in $CONF"
else
	echo "hybrid-now: WARNING -- no blacklist line found in $CONF," >&2
	echo "            the dGPU will stay at D0. Add: blacklist nvidia_drm" >&2
fi

sync
echo
echo "Staged. Reboot to apply, then check it worked with:"
echo "  cat /sys/devices/platform/asus-nb-wmi/gpu_mux_mode      # want 1"
echo "  lsmod | grep nvidia_drm                                 # want no output"
echo "  grep -A2 'Runtime D3' /proc/driver/nvidia/gpus/*/power   # want 'Video Memory: Off'"
