#!/bin/bash

# Install the `paru` AUR helper.
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

# install hyprland lol
paru -S hyprland-git

# install waybar
paru -S waybar-hyprland

# install blue berry

paru -S blueberry

# install astronvim and neovide and whatnot

paru -S neovide
paru -S neovim

git clone --depth 1 https://github.com/AstroNvim/AstroNvim ~/.config/nvim

# install discord 

paru -S discord

# knowledge base obsidian install

paru -S obsidian 

# browser

paru -S firefox-developer-edition

# grub customizer:

paru -S grub-customizer

# GUI file explorer for rare cases:

paru -S nautilus

# gimp is awesome

paru -S gimp-git

# holy i nearly forgot kitty

paru -S kitty

# guvcview

paru -S guvcview-git

# ranger (terminal based file explorer)

paru -S ranger-git

# fish (better shell language)

paru -S fish

echo /usr/local/bin/fish | sudo tee -a /etc/shells

chsh -s /usr/local/bin/fish

# steam

paru -S steam

# tor browser

paru -S tor

# i need whatsapp

paru -S whatsapp-for-linux

# ventoy

paru -S ventoy

# yt-dlp and dlg

paru -S yt-dlp

paru -S yt-dlg

# cava

paru -S cava

# crypto checker

paru -S cointop

# dunst notif manager

paru -S dunst

# fuzzel app menu

paru -S fuzzel

# libreoffice

paru -S libreoffice-fresh

# lutris for gaming

paru -S lutris-git

# btop

paru -S bashtop

# nfetch + fastfetch + pfetch

paru -S neofetch
paru -S fastfetch
paru -S pfetch

# swaylocker

paru -S swaylock-effects

# hyprland config basics

paru -S copyq
paru -S wl-paste
paru -S udiskie
paru -S hyprpaper
paru -S mpvpaper
paru -S fkill
paru -S hyprshot
paru -S gammastep
paru -S volumectl
paru -S brightnessctl


