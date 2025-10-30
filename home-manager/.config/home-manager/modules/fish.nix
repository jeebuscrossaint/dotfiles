{
  config,
  pkgs,
  ...
}: {
  programs.fish = {
    enable = true;

    # Remove greeting
    interactiveShellInit = ''
      set -g fish_greeting
      #fish_config theme choose "Old School"
      starship init fish | source
      # pfetch
      microfetch
    '';

    shellAliases = {
      jit = "git";
      ls = "lsd";
      cl = "clear";
      htop = "btop";
      "11" = "ping 1.1.1.1";
      xcopy = "xclip -sel clip";
      ppctl = "powerprofilesctl";
      # "update-nixos" = "pushd $HOME/dotfiles && nix flake update --commit-lock-file && sudo nixos-rebuild switch --flake . && popd";
      # "new-wallpaper" = "swww img \"$(find ~/wallpapers/ -type f -print0 | shuf -z -n 1)\"";
      "display-update" = "xrandr --output eDP-1 --mode 2560x1600 --rate 240.00 --primary --output  HDMI-1-0 --mode 1920x1080 --rate 60.00 --above eDP-1";
    };

    shellInit = ''
      # Environment variables
      #set -x PATH $HOME/.cargo/bin $PATH
      set -x XDG_DATA_DIRS $XDG_DATA_DIRS:/var/lib/flatpak/exports/share:/home/amarnath/.local/share/flatpak/exports/share
          # set -x XDG_DATA_DIRS "$HOME/.nix-profile/share:$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share"
      #set -x PATH $HOME/go/bin $PATH
      #set -x PATH $HOME/.local/bin $PATH
      #set -x TERMINAL kitty
      # set -x XDG_DATA_DIRS "$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share"
      set -x QT_QPA_PLATFORMTHEME qt5ct
      #set -x PATH $HOME/bin $PATH
      #set -x PATH /usr/local/bin $PATH
      set -x GSK_RENDERER ngl
      set -x NIXPKGS_ALLOW_UNFREE 1
    '';

    functions = {
      findheader = ''
        find /usr/include /usr/local/include -name "$argv[1]" 2>/dev/null
      '';

      colorview = {
        argumentNames = "hex";
        body = ''
          # Remove # if present
          set hex (string replace -r "^#?" "" -- $hex)

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
  };

  # For starship, home-manager also has a module:
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    # You can add your starship config here
    settings = {
      # Add a blank line between shell prompts
      add_newline = true;

      # Format string - customize the prompt layout
      format = ''
        [╭─](bold green)$time $username$sudo$memory_usage $localip$hostname $directory$fill$cmd_duration $battery
        [╰─](bold green)$status$character
      '';

      # Fill module for spacing
      fill = {
        symbol = " ";
      };

      # Custom prompt character
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
        vimcmd_symbol = "[←](bold green)";
      };

      # Status code of last command
      status = {
        disabled = false;
        style = "bold red";
        symbol = "✖ ";
        success_symbol = "";
        format = "[$symbol$status]($style) ";
        map_symbol = true;
      };

      # Time
      time = {
        disabled = false;
        style = "bold white";
        format = "[$time]($style)";
        time_format = "%I:%M:%S %p";
        utc_time_offset = "local";
      };

      # Username
      username = {
        show_always = true;
        style_user = "bold blue";
        style_root = "bold red";
        format = "[$user]($style)";
      };

      # Sudo status
      sudo = {
        disabled = false;
        style = "bold yellow";
        symbol = " 🔓";
        format = "[$symbol]($style)";
      };

      # Memory usage
      memory_usage = {
        disabled = false;
        threshold = 0;
        style = "bold dimmed green";
        symbol = " ";
        format = "[$symbol$ram_pct]($style)";
      };

      # Local IP address
      localip = {
        disabled = false;
        ssh_only = false;
        style = "bold yellow";
        format = "[@$localipv4]($style) ";
      };

      # Hostname
      hostname = {
        ssh_only = false;
        style = "bold cyan";
        format = "[$hostname]($style)";
        disabled = false;
      };

      # Directory
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
        style = "bold purple";
        format = " in [$path]($style)[$read_only]($read_only_style)";
        read_only = " 󰌾";
        read_only_style = "red";
        truncation_symbol = "…/";
        home_symbol = "~";
      };

      # Command duration
      cmd_duration = {
        min_time = 500;
        style = "bold yellow";
        format = "[󱎫 $duration]($style)";
        show_milliseconds = false;
      };

      # Battery
      battery = {
        disabled = false;
        full_symbol = "🔋";
        charging_symbol = "⚡";
        discharging_symbol = "💀";
        unknown_symbol = "❓";
        empty_symbol = "🪫";
        format = "[$symbol$percentage]($style)";
        
        display = [
          {
            threshold = 10;
            style = "bold red";
          }
          {
            threshold = 30;
            style = "bold yellow";
          }
          {
            threshold = 100;
            style = "bold green";
          }
        ];
      };

      # Git stuff (keeping defaults active)
      git_branch = {
        symbol = " ";
        style = "bold purple";
        format = "on [$symbol$branch]($style) ";
      };

      git_status = {
        style = "bold red";
        format = "([$all_status$ahead_behind]($style))";
      };
        };
  };

  # Make sure pkgs includes lsd, btop, etc.
  home.packages = with pkgs; [
    lsd
    btop
    xclip
    # Add other packages you use
  ];
}
