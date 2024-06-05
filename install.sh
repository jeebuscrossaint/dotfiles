#!/bin/bash

# build paru
function build_paru() {
    git clone https://aur.archlinux.org/paru.git
    cd paru 
    makepkg -si
}

function install_system() {
    while read -r pkglist; do
        paru -S "$pkglist"
        done < pkglist.txt
}

function symlink_dotfiles() {
    config_dir="$HOME/.config"
    
}