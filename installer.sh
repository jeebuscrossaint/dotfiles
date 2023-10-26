echo "Welcome to the shlawg config! Would you like to (Re)install all your configurations? This installer is meant for Arch/Arch based distributions."
confirm=""
read -p "Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

# Check if paru is already installed
if ! which paru &> /dev/null; then
  echo "I am installing paru. A goated rust-written AUR helper."
  sudo pacman -S --needed base-devel
  git clone https://aur.archlinux.org/paru.git
  cd paru
  makepkg -si
  cd ..
else
  echo "Paru is already installed. Continuing."
fi

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
