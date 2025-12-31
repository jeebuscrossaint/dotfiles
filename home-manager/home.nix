{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  # ============================================================================
  # Module Imports
  # ============================================================================

  imports = [
    ./modules/fish.nix
    ./modules/kitty.nix
    ./modules/foot.nix
    ./modules/helix.nix
    ./modules/zed.nix
    ./modules/yazi.nix
    ./modules/bat.nix
    ./modules/btop.nix
    ./modules/mangowc.nix
    ./modules/rofi.nix
    ./modules/dunst.nix
    ./modules/mpv.nix
    ./modules/newsboat.nix
    ./modules/nixcord.nix
    ./modules/vscode.nix
    ./modules/micro.nix
    ./modules/labwc.nix
  ];

  # ============================================================================
  # Home Manager Core Configuration
  # ============================================================================

  home.username = "amarnath";
  home.homeDirectory = "/home/amarnath";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  services.home-manager.autoUpgrade = {
    enable = true;
    frequency = "daily";
  };

  # ============================================================================
  # Nixpkgs Configuration
  # ============================================================================

  nixpkgs.config.allowUnfree = true;

  # ============================================================================
  # XDG Configuration
  # ============================================================================

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  xresources.properties = { };

  # ============================================================================
  # Environment Variables
  # ============================================================================

  home.sessionVariables = {
    XCURSOR_THEME = "rose-pine-cursor";
    XCURSOR_SIZE = "12";
    NIXOS_OZONE_WL = "1";
    EDITOR = "hx";
  };

   fonts.fontconfig.enable = true;

  # ============================================================================
  # Theming - Stylix
  # ============================================================================

  stylix = {
    enable = true;
    enableReleaseChecks = false;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/grayscale-dark.yaml";

    fonts = {
      serif = config.stylix.fonts.monospace;
      sansSerif = config.stylix.fonts.monospace;
      monospace = {
        package = pkgs.nerd-fonts.hasklug;
        name = "Hasklug Nerd Font Mono";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };

    fonts.sizes = {
      terminal = 12;
      desktop = 12;
      applications = 12;
      popups = 12;
    };

    opacity = {
      terminal = 1.0;
      popups = 1.0;
      applications = 1.0;
      desktop = 1.0;
    };
  };

  # ============================================================================
  # Development Tools
  # ============================================================================

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
    gitCredentialHelper.hosts = [ "https://github.com" ];
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.nh.enable = true;

  # ============================================================================
  # Applications & Programs
  # ============================================================================

  # Browsers
  programs.qutebrowser.enable = true;
  programs.schizofox.enable = false;

  # Document Viewer
  programs.zathura.enable = true;

  # Application Launcher
  programs.tofi.enable = true;

  # Color Themes
  programs.vivid.enable = true;

  # ============================================================================
  # Services
  # ============================================================================

  services.avizo.enable = true;

  # ============================================================================
  # System Packages
  # ============================================================================

  home.packages = with pkgs; [
    nodePackages.nodejs
    dconf
    sbctl
    playerctl
    bc
    brightnessctl
    libnotify
    autotiling-rs
    systemctl-tui
    gdu
    nmap
    tree
    xxd
    labwc
    pavucontrol
    gnome-tweaks
    nautilus
    blueman
    shotman
    grim
    slurp
    swappy
    hyprpicker
    wlsunset
    mangowc
    avizo
    wasistlos
    cliphist
    wl-clipboard-rs
    whitesur-icon-theme
    whitesur-gtk-theme
    whitesur-cursors
    whitesur-kde
    rose-pine-cursor
    rose-pine-icon-theme
    rose-pine-gtk-theme
    corefonts
    brave
    tor-browser
    slack
    zoom-us
    imv
    imagemagick
    youtube-music
    yt-dlp
    prismlauncher
    lunar-client
    libreoffice-fresh
    standardnotes
    qalculate-gtk
    qemu
    cutter
    hollywood
    cmatrix
    fastfetch
    pipes-rs
    cbonsai
    lowfi
    glow

    # === Custom Inputs ===
    inputs.doomer.packages."${pkgs.stdenv.hostPlatform.system}".default
    inputs.aocli.packages."${pkgs.stdenv.hostPlatform.system}".default
    inputs.ww.packages."${pkgs.stdenv.hostPlatform.system}".default
    inputs.fresh.packages."${pkgs.stdenv.hostPlatform.system}".default
    inputs.woled.packages."${pkgs.stdenv.hostPlatform.system}".default
    inputs.motd.packages."${pkgs.stdenv.hostPlatform.system}".default
  ];
}
