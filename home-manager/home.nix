{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ./modules/newsboat.nix
    ./modules/bat.nix
    ./modules/helix.nix
    ./modules/btop.nix
    ./modules/mpv.nix
    ./modules/dunst.nix
    ./modules/vscode.nix
    ./modules/bemenu.nix
    ./modules/nixcord.nix
    ./modules/chawan.nix
    ./modules/fish.nix
    ./modules/swaylock.nix
    ./modules/rofi.nix
    ./modules/labwc.nix
    ./modules/zed.nix
    ./modules/yazi.nix
    ./modules/kitty.nix
    ./modules/micro.nix
    ./modules/mangowc.nix
    ./modules/foot.nix
  ];

  # IMPORTANT: This tells Home Manager it's running standalone
  #targets.genericLinux.enable = true;

  home.username = "amarnath"; # Change to your username
  home.homeDirectory = "/home/amarnath"; # Change to your home dir

  xresources.properties = { };

  nixpkgs.config.allowUnfree = true;

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  home.packages = with pkgs; [
    dconf
    sbctl
    playerctl
    bc
    jetbrains.clion
    hollywood
    standardnotes
    shotman
    cutter
    avizo
    lunar-client
    wasistlos
    zoom-us
    lowfi
    tor-browser
    whitesur-icon-theme
    whitesur-gtk-theme
    whitesur-cursors
    whitesur-kde
    rose-pine-cursor
    rose-pine-icon-theme
    rose-pine-gtk-theme
    brightnessctl
    mangowc
    libnotify
    pavucontrol
    brave
    qemu
    cliphist
    cmatrix
    fastfetch
    glow
    pipes-rs
    libreoffice-fresh
    tree
    xxd
    prismlauncher
    cbonsai
    gnome-tweaks
    nautilus
    autotiling-rs
    grim
    hyprpicker
    slurp
    swappy
    wlsunset
    wl-clipboard-rs
    labwc
    corefonts
    imagemagick
    imv
    youtube-music
    nmap
    slack
    yt-dlp
    blueman
    qalculate-gtk
    systemctl-tui
    gdu
    inputs.doomer.packages."${pkgs.stdenv.hostPlatform.system}".default
    inputs.aocli.packages."${pkgs.stdenv.hostPlatform.system}".default
    inputs.ww.packages."${pkgs.stdenv.hostPlatform.system}".default
    inputs.fresh.packages."${pkgs.stdenv.hostPlatform.system}".default
    inputs.woled.packages."${pkgs.stdenv.hostPlatform.system}".default
  ];

  programs.nh.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.sessionVariables = {
    XCURSOR_THEME = "rose-pine-cursor";
    XCURSOR_SIZE = "12";
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

  programs.vivid.enable = true;

  programs.tofi.enable = true;

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    gitCredentialHelper.hosts = [ "https://github.com" ];
  };

  # CRITICAL for standalone: This must match your Nix channel version
  home.stateVersion = "26.05"; # Change to match Home Manager version

  stylix.enableReleaseChecks = false;
  programs.home-manager.enable = true;

  services.home-manager.autoUpgrade = {
    enable = true;
    frequency = "daily";
  };
  
  programs.qutebrowser.enable = true;
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
      package = pkgs.nerd-fonts.go-mono;
      name = "GoMono Nerd Font Mono";
    };
    sansSerif = {
      # package = inputs.sf-mono-nerd-font.packages."${pkgs.system}".default;
      # name = "SFMono Nerd Font";
      package = pkgs.nerd-fonts.go-mono;
      name = "GoMono Nerd Font Mono";

    };
    monospace = {
      # package = inputs.sf-mono-nerd-font.packages."${pkgs.system}".default;
      # name = "SFMono Nerd Font";
      package = pkgs.nerd-fonts.go-mono;
      name = "GoMono Nerd Font Mono";
    };
    emoji = {
      package = pkgs.noto-fonts-color-emoji;
      name = "Noto Color Emoji";
    };
  };

  stylix.fonts.sizes = {
    terminal = 12;
    desktop = 12;
    applications = 12;
    popups = 12;
  };

  stylix.opacity.terminal = 1.0;
  stylix.opacity.popups = 1.0;
  stylix.opacity.applications = 1.0;
  stylix.opacity.desktop = 1.0;
}
