#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROTOCOLS_DIR="${SCRIPT_DIR}/protocols"
BUILD_DIR="${SCRIPT_DIR}/build/protocols"

if ! command -v wayland-scanner &> /dev/null; then
    echo "Error: wayland-scanner not found!"
    echo "Please install wayland-protocols package:"
    echo "  Arch Linux:    sudo pacman -S wayland-protocols"
    echo "  Ubuntu/Debian: sudo apt install wayland-protocols"
    echo "  Fedora:        sudo dnf install wayland-protocols-devel"
    exit 1
fi

mkdir -p "${BUILD_DIR}"

echo "Generating protocol bindings..."

echo "  wlr-layer-shell-unstable-v1..."
wayland-scanner client-header \
    "${PROTOCOLS_DIR}/wlr-layer-shell-unstable-v1.xml" \
    "${BUILD_DIR}/wlr-layer-shell-unstable-v1-client-protocol.h"

wayland-scanner private-code \
    "${PROTOCOLS_DIR}/wlr-layer-shell-unstable-v1.xml" \
    "${BUILD_DIR}/wlr-layer-shell-unstable-v1-protocol.c"

echo "  xdg-shell..."
wayland-scanner client-header \
    "${PROTOCOLS_DIR}/xdg-shell.xml" \
    "${BUILD_DIR}/xdg-shell-client-protocol.h"

wayland-scanner private-code \
    "${PROTOCOLS_DIR}/xdg-shell.xml" \
    "${BUILD_DIR}/xdg-shell-protocol.c"

echo "  Fixing C++ keyword collision..."
if [[ -f "${BUILD_DIR}/wlr-layer-shell-unstable-v1-client-protocol.h" ]]; then
    sed -i 's/const char \*namespace)/const char *name_space)/g' \
        "${BUILD_DIR}/wlr-layer-shell-unstable-v1-client-protocol.h"
    sed -i 's/, namespace)/, name_space)/g' \
        "${BUILD_DIR}/wlr-layer-shell-unstable-v1-client-protocol.h"
fi

if [[ -f "${BUILD_DIR}/wlr-layer-shell-unstable-v1-protocol.c" ]]; then
    sed -i 's/const char \*namespace)/const char *name_space)/g' \
        "${BUILD_DIR}/wlr-layer-shell-unstable-v1-protocol.c"
    sed -i 's/, namespace)/, name_space)/g' \
        "${BUILD_DIR}/wlr-layer-shell-unstable-v1-protocol.c"
fi

echo ""
echo "Done! Generated:"
echo "  ${BUILD_DIR}/wlr-layer-shell-unstable-v1-client-protocol.h"
echo "  ${BUILD_DIR}/wlr-layer-shell-unstable-v1-protocol.c"
echo "  ${BUILD_DIR}/xdg-shell-client-protocol.h"
echo "  ${BUILD_DIR}/xdg-shell-protocol.c"
echo ""
echo "Note: renamed 'namespace' → 'name_space' for C++ compatibility"
