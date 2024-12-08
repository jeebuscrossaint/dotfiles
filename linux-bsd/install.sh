#!/usr/bin/env bash

# Check if the .config directory exists
if [ ! -d "$HOME/.config" ]; then
    mkdir -p "$HOME/.config"
    echo "Created .config directory"
fi

# Check if the 'stow' command is available
if command -v stow >/dev/null 2>&1; then
    echo "stow command found"
else
    echo "stow command not found. Please install it using your package manager."
fi

stow .
