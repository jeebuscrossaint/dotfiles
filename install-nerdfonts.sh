#!/bin/sh
# install-nerdfonts.sh — download and install all Nerd Fonts
# Works on Linux and OpenBSD (requires curl, xz, tar, fc-cache)


FONTS_DIR="${HOME}/.local/share/fonts/NerdFonts"
TMPDIR="${TMPDIR:-/tmp}/nerdfonts-install"
mkdir -p "$FONTS_DIR" "$TMPDIR"

for cmd in curl xz tar fc-cache; do
    if ! command -v "$cmd" > /dev/null 2>&1; then
        echo "error: $cmd is required"
        exit 1
    fi
done

API="https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest"

echo "Fetching latest Nerd Fonts release..."
RELEASE=$(curl -fsSL "$API")
VERSION=$(printf '%s' "$RELEASE" | grep '"tag_name"' | sed 's/.*"tag_name": *"\(.*\)".*/\1/')
echo "Version: $VERSION"

BASE_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${VERSION}"

FONTS=$(printf '%s' "$RELEASE" | grep '"name"' | grep '\.tar\.xz"' | sed 's/.*"name": *"\(.*\)".*/\1/')

TOTAL=$(printf '%s\n' "$FONTS" | wc -l | tr -d ' ')
COUNT=0

for font in $FONTS; do
    COUNT=$(( COUNT + 1 ))
    printf '[%d/%d] %s\n' "$COUNT" "$TOTAL" "$font"
    tmp="$TMPDIR/$font"
    if ! curl -fsSL --connect-timeout 10 --max-time 120 -o "$tmp" "${BASE_URL}/${font}"; then
        echo "  skipped (download failed or timed out)"
        rm -f "$tmp"
        continue
    fi
    xz -dc "$tmp" | tar xf - -C "$FONTS_DIR"
    rm -f "$tmp"
done

rmdir "$TMPDIR" 2>/dev/null || true

echo "Updating font cache..."
fc-cache -f "$FONTS_DIR"
echo "Done — $COUNT font families installed to $FONTS_DIR"
