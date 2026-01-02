{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{

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
    ./modules/i3.nix
    ./modules/i3status-rust.nix
    ./modules/picom.nix
  ];

  home.username = "amarnath";
  home.homeDirectory = "/home/amarnath";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  services.home-manager.autoUpgrade = {
    enable = true;
    frequency = "daily";
  };

 
  nixpkgs.config.allowUnfree = true;

   xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  xresources.properties = { };

   home.sessionVariables = {
    XCURSOR_THEME = "rose-pine-cursor";
    XCURSOR_SIZE = "12";
    NIXOS_OZONE_WL = "1";
    EDITOR = "hx";
  };

  fonts.fontconfig.enable = true;

   stylix = {
    enable = true;
    enableReleaseChecks = false;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/kanagawa-dragon.yaml";

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
  programs.qutebrowser.enable = true;
  programs.zathura.enable = true;
  programs.vivid.enable = true;
  services.avizo.enable = true;

  home.packages = with pkgs; [
    nodePackages.nodejs
    jetbrains.clion
    autotiling
    vibrantlinux
    dconf
    xorg.xinit
    xauth
    sbctl
    playerctl
    bc
    brightnessctl
    libnotify
    gdu
    nmap
    tree
    # labwc
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
    guvcview
    xss-lock
    xsecurelock
    feh
    flameshot
    xorg.xinput
    xorg.xset
    unclutter-xfixes
    font-awesome
    gammastep

    # === Custom Inputs ===
    inputs.ww.packages."${pkgs.stdenv.hostPlatform.system}".default
    inputs.fresh.packages."${pkgs.stdenv.hostPlatform.system}".default
    inputs.woled.packages."${pkgs.stdenv.hostPlatform.system}".default
    inputs.motd.packages."${pkgs.stdenv.hostPlatform.system}".default
  ];
}
