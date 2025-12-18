{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    # ./modules/newsboat.nix
    ./modules/bat.nix
    # ./modules/foot.nix
    ./modules/helix.nix
    # ./modules/hyprlock.nix
    # ./modules/fd.nix
    ./modules/btop.nix
     ./modules/mpv.nix
    ./modules/dunst.nix
    # ./modules/hypridle.nix
    # ./modules/hyprlock.nix
    # ./modules/hyprland.nix
    ./modules/vscode.nix
    ./modules/bemenu.nix
    ./modules/nixcord.nix
    ./modules/chawan.nix
     # ./modules/sway.nix
     ./modules/fish.nix
     ./modules/swaylock.nix
     ./modules/rofi.nix
     # ./modules/swayidle.nix
     # ./modules/sway-fix.nix
     ./modules/labwc.nix
     ./modules/zed.nix
     ./modules/yazi.nix
     # ./modules/wayfire.nix
     ./modules/kitty.nix
     # ./modules/nvf.nix
     ./modules/micro.nix
     ./modules/mangowc.nix
     # ./modules/i3.nix
     # ./modules/i3-fix.nix
     # ./modules/sxwm.nix
     # ./modules/picom.nix
     # ./modules/xmonad.nix
     # ./modules/awesome.nix
     # ./modules/spectrwm.nix
     # ./modules/river.nix
  ];

  # IMPORTANT: This tells Home Manager it's running standalone
  targets.genericLinux.enable = true;

  home.username = "amarnath";  # Change to your username
  home.homeDirectory = "/home/amarnath";  # Change to your home dir

  xresources.properties = {};

  nixpkgs.config.allowUnfree = true;

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  home.packages = with pkgs; [
    hollywood
    standardnotes
    shotman
    cutter
    avizo
    lunar-client
    wasistlos
    lowfi
    tor-browser
    whitesur-icon-theme
    whitesur-gtk-theme
    whitesur-cursors
    rose-pine-cursor
    rose-pine-icon-theme
    rose-pine-gtk-theme
    brightnessctl
    nix-search
    # gnomeExtensions.blur-my-shell
    # gnomeExtensions.burn-my-windows
    # gnomeExtensions.weather-or-not
    # gnomeExtensions.rounded-window-corners-reborn
    # gnomeExtensions.mpris-label
    # gnomeExtensions.fly-pie
    # gnomeExtensions.desktop-clock
    # gnomeExtensions.dash-to-dock
    # gnomeExtensions.paperwm
    # Add your custom packages
    inputs.doomer.packages."${pkgs.system}".default
    inputs.aocli.packages."${pkgs.system}".default
    inputs.ww.packages."${pkgs.system}".default
    inputs.motd.packages."${pkgs.system}".default
  ];

  
  home.sessionVariables = {
    XCURSOR_THEME = "rose-pine-cursor";
    XCURSOR_SIZE = "24";
    NIXOS_OZONE_WL = "1";
    EDITOR = "hx";
  };
  
  fonts.fontconfig.enable = true;

  programs.git = {
    enable = true;
    settings = {
      credential.helper = "store";
      user.name = "jeebuscrossaint";
      user.email = "thediamond270@gmail.com";
    };
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    gitCredentialHelper.hosts = ["https://github.com"];
  };

  # CRITICAL for standalone: This must match your Nix channel version
  home.stateVersion = "25.11";  # Change to match Home Manager version

  stylix.enableReleaseChecks = false;
  programs.home-manager.enable = true;

  services.home-manager.autoUpgrade.useFlake = true;
  programs.qutebrowser.enable = true;
  programs.chromium.enable = true;
  programs.schizofox.enable = false;
  programs.zathura.enable = true;
  services.avizo.enable = true;

    
  # Stylix configuration (optional, remove if you don't want it)
  stylix.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/irblack.yaml";
  
 
    stylix.fonts = {
    serif = {
      # package = inputs.sf-mono-nerd-font.packages."${pkgs.system}".default;
      # name = "SFMono Nerd Font";
      package = pkgs.nerd-fonts.ubuntu-mono;
      name = "UbuntuMono Nerd Font Mono";
    };
    sansSerif = {
      # package = inputs.sf-mono-nerd-font.packages."${pkgs.system}".default;
      # name = "SFMono Nerd Font";
      package = pkgs.nerd-fonts.ubuntu-mono;
      name = "UbuntuMono Nerd Font Mono";
    
    };
    monospace = {
      # package = inputs.sf-mono-nerd-font.packages."${pkgs.system}".default;
      # name = "SFMono Nerd Font";
      package = pkgs.nerd-fonts.ubuntu-mono;
      name = "UbuntuMono Nerd Font Mono";
    };
    emoji = {
      package = pkgs.noto-fonts-color-emoji;
      name = "Noto Color Emoji";
    };
  };

  stylix.fonts.sizes = {
    terminal = 14;
    desktop = 14;
    applications = 14;
    popups = 14;
  };

  stylix.opacity.terminal = 1.0;
  stylix.opacity.popups = 1.0;
  stylix.opacity.applications = 1.0;
  stylix.opacity.desktop = 1.0;
}
