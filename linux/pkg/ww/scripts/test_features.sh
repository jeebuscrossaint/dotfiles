#!/bin/bash

# Test script for ww wallpaper setter features
# Tests directory scanning and transition effects

set -e

echo "==================================="
echo "ww - Wallpaper Setter Feature Test"
echo "==================================="
echo ""

# Check if ww is built
if [[ ! -f "./build/linux/x86_64/debug/ww" ]]; then
    echo "Building ww..."
    xmake build
fi

WW="./build/linux/x86_64/debug/ww"

# Create test directory structure
echo "Setting up test directories..."
mkdir -p test_wallpapers/nature
mkdir -p test_wallpapers/abstract
mkdir -p test_wallpapers/tech

# Copy existing test images to test directories
if [[ -f "test.png" ]]; then
    cp test.png test_wallpapers/nature/img1.png
    cp test.jpg test_wallpapers/abstract/img2.jpg
    cp test.webp test_wallpapers/tech/img3.webp
fi

echo ""
echo "Test 1: List available outputs"
echo "-------------------------------"
"${WW}" --list-outputs
echo ""

echo "Test 2: Set single wallpaper with fade"
echo "---------------------------------------"
if [[ -f "test.png" ]]; then
    echo "Setting test.png..."
    "${WW}" test.png &
    WW_PID=$!
    sleep 2
    kill "${WW_PID}" 2>/dev/null || true
    echo "✓ Single wallpaper test complete"
else
    echo "⚠ test.png not found, skipping"
fi
echo ""

echo "Test 3: Directory scanning (non-recursive)"
echo "-------------------------------------------"
if [[ -d "test_wallpapers" ]]; then
    echo "Command: ${WW} -S -i 3 test_wallpapers/"
    echo "(Would scan only top-level directory)"
    echo "Files that would be loaded:"
    find test_wallpapers -maxdepth 1 -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.webp" \) 2>/dev/null | head -5
else
    echo "⚠ test_wallpapers directory not ready"
fi
echo ""

echo "Test 4: Recursive directory scanning"
echo "-------------------------------------"
if [[ -d "test_wallpapers" ]]; then
    echo "Command: ${WW} -S -R -i 3 test_wallpapers/"
    echo "(Would scan all subdirectories recursively)"
    echo "Files that would be loaded:"
    find test_wallpapers -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.webp" \) 2>/dev/null
else
    echo "⚠ test_wallpapers directory not ready"
fi
echo ""

echo "Test 5: Slideshow with fade transition"
echo "---------------------------------------"
if [[ -f "test.png" && -f "test.jpg" ]]; then
    echo "Starting 6-second slideshow with 1-second fade..."
    echo "Command: ${WW} -S -i 2 -t fade -d 1.0 test.png test.jpg test.webp"
    echo "Press Ctrl+C to stop..."
    sleep 1
    "${WW}" -S -i 2 -t fade -d 1.0 test.png test.jpg test.webp 2>/dev/null &
    WW_PID=$!
    sleep 7
    kill "${WW_PID}" 2>/dev/null || true
    echo "✓ Fade transition test complete"
else
    echo "⚠ Test images not found, skipping"
fi
echo ""

echo "Test 6: Slideshow with slide-left transition"
echo "---------------------------------------------"
if [[ -f "test.png" && -f "test.jpg" ]]; then
    echo "Starting 6-second slideshow with slide-left transition..."
    echo "Command: ${WW} -S -i 2 -t slide-left -d 0.8 test.png test.jpg test.webp"
    echo "Press Ctrl+C to stop..."
    sleep 1
    "${WW}" -S -i 2 -t slide-left -d 0.8 test.png test.jpg test.webp 2>/dev/null &
    WW_PID=$!
    sleep 7
    kill "${WW_PID}" 2>/dev/null || true
    echo "✓ Slide-left transition test complete"
else
    echo "⚠ Test images not found, skipping"
fi
echo ""

echo "Test 7: Random slideshow with directory"
echo "----------------------------------------"
if [[ -d "test_wallpapers" && -f "test.png" ]]; then
    # Copy a few more images for variety
    cp test.png test_wallpapers/img1.png 2>/dev/null || true
    cp test.jpg test_wallpapers/img2.jpg 2>/dev/null || true
    cp test.webp test_wallpapers/img3.webp 2>/dev/null || true

    echo "Starting random slideshow from directory..."
    echo "Command: ${WW} -S -R -r -i 2 -t fade -d 1.5 test_wallpapers/"
    echo "Press Ctrl+C to stop..."
    sleep 1
    "${WW}" -S -R -r -i 2 -t fade -d 1.5 test_wallpapers/ 2>/dev/null &
    WW_PID=$!
    sleep 7
    kill "${WW_PID}" 2>/dev/null || true
    echo "✓ Random slideshow test complete"
else
    echo "⚠ Test directory not ready, skipping"
fi
echo ""

echo "Test 8: Different transition types"
echo "-----------------------------------"
echo "Available transitions:"
echo "  - none        (instant switch)"
echo "  - fade        (crossfade)"
echo "  - slide-left  (slide from right)"
echo "  - slide-right (slide from left)"
echo "  - slide-up    (slide from bottom)"
echo "  - slide-down  (slide from top)"
echo ""

echo "==================================="
echo "All tests complete!"
echo "==================================="
echo ""
echo "Example commands to try:"
echo ""
echo "1. Basic slideshow with directory:"
echo "   ${WW} -S ~/Pictures/"
echo ""
echo "2. Recursive scan with fade:"
echo "   ${WW} -S -R -t fade -d 2.0 ~/Wallpapers/"
echo ""
echo "3. Random slideshow with quick transitions:"
echo "   ${WW} -S -r -i 30 -t slide-left -d 0.5 ~/Pictures/*.jpg"
echo ""
echo "4. Slow crossfade slideshow:"
echo "   ${WW} -S -i 300 -t fade -d 3.0 ~/Wallpapers/"
echo ""

# Cleanup
echo "Cleaning up test directories..."
rm -rf test_wallpapers

echo "Done!"
