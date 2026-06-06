# Linux

**Requirements:** GNU Stow
```sh
# Install stow first
sudo pacman -S stow        # Arch/Manjaro
sudo apt install stow      # Debian/Ubuntu

# Install dotfiles
./install.sh               # Symlinks linux/ to $HOME using stow

# Uninstall dotfiles
stow -D linux              # Remove symlinks
```

### Structure
```
linux/.config/      # All XDG config files
  bat/
  bto
  dunst/
  fish/
  helix/
  i3/
  kitty/
  labwc/
  mango/
  rofi/
  sway/
  swaylock/
  starship.toml

windows/
  starship.toml
  Microsoft.PowerShell_profile.ps1
  windowspkgs.txt
```

# Linux Dotfiles

Place your Linux configuration files here.

## Structure

```
linux/
├── .config/          # XDG config directory files
│   ├── i3/          # i3 window manager config
│   ├── rofi/        # rofi launcher config
│   ├── kitty/       # kitty terminal config
│   └── ...          # any other .config programs
├── .bashrc          # bash configuration
├── .zshrc           # zsh configuration
└── ...              # any other dotfiles
```

## Adding Your Dotfiles

1. Copy your config directories into `.config/`:
   ```sh
   cp -r ~/.config/i3 linux/.config/
   cp -r ~/.config/rofi linux/.config/
   ```

2. Copy standalone dotfiles into `linux/`:
   ```sh
   cp ~/.bashrc linux/
   cp ~/.zshrc linux/
   ```

3. Run the installer from the repo root:
   ```sh
   ./install.sh
   ```

The script will create symlinks from your home directory to the files in this repo.
