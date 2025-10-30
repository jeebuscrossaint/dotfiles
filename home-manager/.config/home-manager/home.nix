{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    # ./modules/newsboat.nix
    # ./modules/bat.nix
    ./modules/foot.nix
    ./modules/helix.nix
    ./modules/hyprlock.nix
    # ./modules/fd.nix
    ./modules/btop.nix
     ./modules/mpv.nix
    ./modules/dunst.nix
    ./modules/hypridle.nix
    ./modules/vscode.nix
    ./modules/bemenu.nix
    ./modules/nixcord.nix
    ./modules/chawan.nix
      ./modules/sway.nix
    ./modules/fish.nix
     ./modules/swaylock.nix
     ./modules/rofi.nix
     ./modules/swayidle.nix
     ./modules/sway-fix.nix
  ];

  # IMPORTANT: This tells Home Manager it's running standalone
  targets.genericLinux.enable = true;

  home.username = "amarnath";  # Change to your Arch username
  home.homeDirectory = "/home/amarnath";  # Change to your Arch home dir

  xresources.properties = {};

  nixpkgs.config.allowUnfree = true;

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  home.packages = with pkgs; [
    # vulkan-tools
    # vulkan-loader
    # vulkan-validation-layers
    # vulkan-extension-layer
    # libnotify
    # xwallpaper
    bc
    swww
    hollywood
    cmatrix
    cbonsai
    pipes-rs
    # pcmanfm
    gdu
    standardnotes
    # guvcview
    shotman
    less
    # hyprshot
    # hyprpicker
    # libsecret
    # wlay
    # youtube-music
    # cutter
    # ghidra
    qalculate-gtk
    fastfetch
    tree
    # fzf
    # which
    # btop
    # pciutils
    autotiling-rs
    ipfetch
    wl-clipboard-rs
    swappy
    slurp
    grim
    jq
    # slurp
    lsd
    # microfetch
    avizo
    cliphist
    # udiskie
    # gamemode
    font-awesome
    # gnome-tweaks
    # gtk-engine-murrine
    # gnome-themes-extra
    # xclip
    # wireshark
    blueberry
    gparted
    lunar-client
    # libreoffice-qt6-fresh
    whatsapp-for-linux
    glow
    # pfetch-rs
    yazi
    corefonts
    slack
    # gamemode
    imv
    # sbctl
    lowfi
    pavucontrol
    tor-browser
    whitesur-icon-theme
    whitesur-gtk-theme
    whitesur-cursors
    rose-pine-cursor
    rose-pine-icon-theme
    rose-pine-gtk-theme
    networkmanagerapplet
    guvcview
    # cheese
    snapshot
    brightnessctl
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
    # inputs.doomer.packages."${pkgs.system}".default
    # inputs.aocli.packages."${pkgs.system}".default
    # inputs.sf-mono-nerd-font.packages."${pkgs.system}".default
  ];

  # programs.librewolf.enable = true;
  programs.tmux.enable = true;

  home.sessionVariables = {
    XCURSOR_THEME = "rose-pine-cursor";
    XCURSOR_SIZE = "24";
    NIXOS_OZONE_WL = "1";
    EDITOR = "helix";
  };
  
  fonts.fontconfig.enable = true;

  programs.git = {
    enable = true;
    # user.name = "jeebuscrossaint";
    # user.email = "thediamond270@gmail.com";
    settings = {
      credential.helper = "store";
      user.name = "jeebuscrossaint";
      user.email = "thediamond270@gmail.com";
    };
  };

  # programs.ssh = {
    # enable = true;
    # addKeysToAgent = "yes";
  # };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    gitCredentialHelper.hosts = ["https://github.com"];
  };

  # CRITICAL for standalone: This must match your Nix channel version
  home.stateVersion = "25.05";  # Change to match Home Manager version

  programs.home-manager.enable = true;

  services.home-manager.autoUpgrade.useFlake = true;
  programs.cava.enable = true;
  programs.nh.enable = true;
  programs.qutebrowser.enable = false;
  programs.chromium.enable = true;
  programs.schizofox.enable = false;
  programs.zathura.enable = true;
  services.avizo.enable = true;

    
  # Stylix configuration (optional, remove if you don't want it)
  stylix.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/material-darker.yaml";
  
  stylix.fonts = {
    serif = {
      package = inputs.sf-mono-nerd-font.packages."${pkgs.system}".default;
      name = "SFMono Nerd Font";
    };
    sansSerif = {
      package = inputs.sf-mono-nerd-font.packages."${pkgs.system}".default;
      name = "SFMono Nerd Font";
    };
    monospace = {
      package = inputs.sf-mono-nerd-font.packages."${pkgs.system}".default;
      name = "SFMono Nerd Font";
    };
    emoji = {
      package = pkgs.noto-fonts-emoji;
      name = "Noto Color Emoji";
    };
  };

  stylix.fonts.sizes = {
    terminal = 10;
    desktop = 10;
    applications = 10;
    popups = 10;
  };

  stylix.opacity.terminal = 1.0;
  stylix.opacity.popups = 1.0;
  stylix.opacity.applications = 1.0;
  stylix.opacity.desktop = 1.0;
}
