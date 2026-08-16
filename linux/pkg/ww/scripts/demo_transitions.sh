#!/bin/bash

# Demo script for ww transition effects
# Shows off all the new transitions with different settings

echo "=========================================="
echo "ww - Transition Effects Demo"
echo "=========================================="
echo ""

WW="./build/linux/x86_64/release/ww"

if [[ ! -f "${WW}" ]]; then
    echo "Error: ww binary not found. Please build first with 'xmake build'"
    exit 1
fi

# Check if images directory is provided
if [[ -z "$1" ]]; then
    echo "Usage: $0 <path-to-images>"
    echo ""
    echo "Example: $0 ~/Pictures/wallpapers/"
    echo "         $0 ~/Pictures/*.jpg"
    exit 1
fi

IMAGES=("$@")
DURATION=2.0
FPS=60
INTERVAL=4

echo "Settings:"
echo "  Images: ${IMAGES[*]}"
echo "  Transition duration: ${DURATION}s"
echo "  Frame rate: ${FPS} FPS"
echo "  Interval: ${INTERVAL}s"
echo ""
echo "Press Ctrl+C to skip to next transition or exit"
echo ""
echo "=========================================="
echo ""

# Array of all transitions with descriptions
declare -a TRANSITIONS=(
    "fade:Smooth crossfade between images"
    "slide-left:Slide from right to left"
    "slide-right:Slide from left to right"
    "slide-up:Slide from bottom to top"
    "slide-down:Slide from top to bottom"
    "zoom-in:Zoom in while fading"
    "zoom-out:Zoom out while fading"
    "circle-open:Circular reveal from center"
    "circle-close:Circular collapse to center"
    "wipe-left:Curtain wipe left"
    "wipe-right:Curtain wipe right"
    "wipe-up:Curtain wipe up"
    "wipe-down:Curtain wipe down"
    "dissolve:Random pixel dissolve"
    "pixelate:Pixelate transition effect"
)

# Function to run a transition demo
run_demo() {
    local transition="$1"
    local description="$2"

    echo "[${transition}]"
    echo "  ${description}"
    echo "  Running for 15 seconds..."
    echo ""

    timeout 15s "${WW}" -S -m fill -t "${transition}" -d "${DURATION}" -f "${FPS}" -i "${INTERVAL}" "${IMAGES[@]}" 2>/dev/null

    echo ""
}

# Run through all transitions
for item in "${TRANSITIONS[@]}"; do
    IFS=':' read -r transition description <<< "${item}"
    run_demo "$transition" "$description"
    sleep 0.5
done

echo "=========================================="
echo "Demo Complete!"
echo "=========================================="
echo ""
echo "Try these commands yourself:"
echo ""
echo "# Smooth 60 FPS fade"
echo "${WW} -S -m fill -t fade -d 2.0 -f 60 -i 300 ${IMAGES[*]}"
echo ""
echo "# Cool zoom effect"
echo "${WW} -S -m fill -t zoom-in -d 2.5 -f 60 -i 300 ${IMAGES[*]}"
echo ""
echo "# Circle wipe"
echo "${WW} -S -m fill -t circle-open -d 1.5 -f 60 -i 300 ${IMAGES[*]}"
echo ""
echo "# Pixelate effect"
echo "${WW} -S -m fill -t pixelate -d 2.0 -f 60 -i 300 ${IMAGES[*]}"
echo ""
echo "# Random order with dissolve"
echo "${WW} -S -R -r -m fill -t dissolve -d 2.0 -f 60 -i 300 ${IMAGES[*]}"
echo ""

# Quick comparison demo
echo "=========================================="
echo "Want to compare transitions side-by-side?"
echo "=========================================="
echo ""
echo "Run these in separate terminals:"
echo ""
echo "# Terminal 1 (Fade)"
echo "${WW} -S -m fill -t fade -d 2.0 -f 60 -i 10 ${IMAGES[*]}"
echo ""
echo "# Terminal 2 (Circle)"
echo "${WW} -S -m fill -t circle-open -d 2.0 -f 60 -i 10 ${IMAGES[*]}"
echo ""

echo "=========================================="
echo "Tip: Run as daemon for auto-restore!"
echo "=========================================="
echo ""
echo "Add to your compositor config:"
echo "exec-once = ${WW} --daemon"
echo ""
echo "Then set wallpapers normally - they'll persist!"
echo ""

exit 0
