{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    
    # Remove greeting
    interactiveShellInit = ''
      set -g fish_greeting
      fish_config theme choose "Old School"
      source ~/.cache/wal/colors.fish
      starship init fish | source
      ~/.cache/wal/colors-tty.sh
      pfetch
      ls
    '';
    
    shellAliases = {
      drake = "neovide";
      jit = "git";
      # hx = "helix";  # Commented out in your config
      ls = "lsd";
      # sudo = "doas";  # Commented out in your config
      cl = "clear";
      htop = "btop";
      "11" = "ping 1.1.1.1";
      "11gnu" = "ping gnu.org";
      xcopy = "xclip -sel clip";
      ppctl = "powerprofilesctl";
      "update-nixos" = "pushd $HOME/dotfiles && nix flake update --commit-lock-file && sudo nixos-rebuild switch --flake . && popd";
    };
    
    shellInit = ''
      # Environment variables
      set -x PATH $HOME/.cargo/bin $PATH
      set -x XDG_DATA_DIRS $XDG_DATA_DIRS:/var/lib/flatpak/exports/share:/home/amarnath/.local/share/flatpak/exports/share
      set -x PATH $HOME/go/bin $PATH
      set -x PATH $HOME/.local/bin $PATH
      set -x TERMINAL kitty
      set -x XDG_DATA_DIRS "$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share"
      set -x QT_QPA_PLATFORMTHEME qt5ct
      set -x PATH $HOME/bin $PATH
      set -x PATH /usr/local/bin $PATH
      set -x GSK_RENDERER ngl
    '';
    
    functions = {
      findheader = ''
        find /usr/include /usr/local/include -name "$argv[1]" 2>/dev/null
      '';
      
      colorview = {
        argumentNames = "hex";
        body = ''
          # Remove # if present
          set hex (string replace -r '^#?' '' -- $hex)
          
          set -l r (echo $hex | cut -c 1-2)
          set -l g (echo $hex | cut -c 3-4)
          set -l b (echo $hex | cut -c 5-6)
          
          printf "\033[48;2;%d;%d;%dm     \033[0m %s\n" \
              (printf "%d" "0x$r") \
              (printf "%d" "0x$g") \
              (printf "%d" "0x$b") \
              $hex
        '';
      };
    };
    
    plugins = [
      # If you want to add zoxide as a plugin, you can do something like this:
      # {
      #   name = "zoxide";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "kidonng";
      #     repo = "zoxide.fish";
      #     rev = "fd993e8"; # Replace with actual commit hash
      #     sha256 = "..."; # Fill in the SHA256 hash
      #   };
      # }
    ];
  };
  
  # For zoxide, home-manager has a dedicated module:
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    options = []; # Add any zoxide options you need
  };
  
  # For starship, home-manager also has a module:
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    # You can add your starship config here
    # settings = { ... };
  };
  
  # Make sure pkgs includes lsd, btop, etc.
  home.packages = with pkgs; [
    lsd
    btop
    xclip
    pfetch
    # Add other packages you use
  ];
}
