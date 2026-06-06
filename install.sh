#!/usr/bin/env bash

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${GREEN}=>${NC} $*"; }
warn()    { echo -e "${YELLOW}=>${NC} $*"; }
error()   { echo -e "${RED}=>${NC} $*"; exit 1; }

# Check dependencies
command -v stow &>/dev/null || error "GNU Stow is not installed. Install with: sudo pacman -S stow"

cd "$DOTFILES_DIR"

# Stow linux configs
info "Symlinking dotfiles..."
stow -v -t "$HOME" linux --restow 2>&1 | grep "^LINK" | sed 's/^/  /'
echo ""

# Optionally apply coat theme
if command -v coat &>/dev/null; then
    info "Applying coat theme..."
    coat apply
else
    warn "coat not found — skipping theme. Install from: https://github.com/jeebuscrossaint/coat"
fi

echo ""
info "Done! Open a new shell to pick up PATH changes."
