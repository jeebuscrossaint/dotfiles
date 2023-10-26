#!/bin/bash
echo "*==============================================================*"
printf "\n"
echo "Welcome to the shlawg config! Would you like to (Re)install all your configurations? This installer is meant for Arch/Arch based distributions. Specifically EndeavorOS in mind. Please do not send issues if this repository doesn't work for your distro. Also this whole script may take a while depending on your hardware and internet connection. Yeah. Pplease have an internet connection."
printf "\n"
echo "*==============================================================*"
confirm=""
read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

# Check if paru is already installed
if ! which paru &> /dev/null; then
  echo "I am installing paru. A goated rust-written AUR helper."
  cd ..
  sudo pacman -S --needed base-devel
  git clone https://aur.archlinux.org/paru.git
  cd paru
  makepkg -si
  cd ..
  cd theshlawg/
else
  echo "Paru is already installed. Continuing."
fi
# nvidia gpu check
echo "Do you have an NVIDIA GPU? Read the text below to check if you do or do not. IF it says NVIDIA anywhere then answer yes, if not answer no. This is due to NVIDIA's drivers being closed source like a bum."
lspci -v -s $(lspci | grep ' VGA ' | cut -d" " -f 1)
gpuconfirm=""
read -p "Explicitly answer Y or N to the above inquiry.
" gpuconfirm

if [ $gpuconfirm = Y ]; then
  echo "Installing NVIDIA pkgs."
  paru -S --needed - < nvidiapkglist.txt
elif [ $gpuconfirm = N ]; then
  echo "Installing normal pkgs."
  paru -S --needed - < pkglist.txt
else
  echo "It's a yes or no question, you bum."
fi

chsh -s /usr/bin/fish
fish_config theme choose oldschool
echo "Made default shell fish for this user."

echo "Now installing theshlawg's dotfiles."
echo "Installing .config files."

cd dunst
cp -r * ~/.config/dunst
cd ..
cd fuzzel
cp -r * ~/.config/fuzzel
cd ..
cd fish
cp -r * ~/.config/fish
cd ..
cd hyprland
cp -r * ~/.config/hypr
cd ..
cd kitty
cp -r * ~/.config/kitty
cd ..
cd swaylock
cp -r * ~/.config/swaylock/
cd ..
cd waybar
cp -r * ~/.config/waybar
cd ..
cd ~
git clone https://github.com/jeebuscrossaint/neovimplugins
cd neovimplugins
mv init.lua ~/.config/nvim
cd ~/neovimplugins/
cp -r * ~/.config/nvim/lua
cd ..
git clone --depth 1 https://github.com/AstroNvim/AstroNvim ~/.config/nvim

echo "Everything should be complete. Be sure to report any issues to the issues tab on this repository. https://github.com/jeebuscrossaint/theshlawg"
echo "Also star and fork if u like it."