{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./modules/fish.nix
    ./modules/alacritty.nix
    ./modules/bat.nix
    ./modules/foot.nix
    ./modules/tealdeer.nix
    ./modules/bottom.nix
    ./modules/helix.nix
    ./modules/hyprlock.nix
    ./modules/fd.nix
    ./modules/btop.nix
    ./modules/rofi.nix
    ./modules/kitty.nix
    ./modules/mangohud.nix
    ./modules/micro.nix
    ./modules/mpv.nix
    ./modules/waybar.nix
    ./modules/hyprland.nix
    ./modules/spectrwm.nix
    ./modules/swaylock.nix
    ./modules/dunst.nix
    ./modules/fnott.nix
    ./modules/sway.nix
    ./modules/sway-fix.nix
    ./modules/hypridle.nix
    ./modules/picom.nix
    ./modules/i3.nix
    ./modules/vscode.nix
    ./modules/nvf.nix
    ./modules/fuzzel.nix
    ./modules/zed.nix
    ./modules/hyprpaper.nix
    ./modules/fht.nix
    ./modules/twmn.nix
    ./modules/bemenu.nix
    ./modules/i3status-rust.nix
    ./modules/nixcord.nix
    ./modules/i3-fix.nix
    ./modules/nushell.nix
    ./modules/bash.nix
  ];

  home.username = "amarnath";
  home.homeDirectory = "/home/amarnath";

  xresources.properties = {
  };

  /*
    home.pointerCursor.x11.enable = true;
  home.pointerCursor.gtk.enable = true;
  */

  home.packages = with pkgs; [
    swww
    pcmanfm
    shotman
    hyprshot
    hyprpicker
    libsecret
    wlay
    swaybg
    swaynotificationcenter
    #drawing
    cutter
    ghidra
    qalculate-gtk
    #qemu_full
    #qemu-user
    fastfetch
    tree
    fzf
    which
    btop
    pciutils
    #vesktop
    swayrbar
    #pfetch-rs
    autotiling-rs
    #autotiling
    ipfetch
    wl-clipboard-rs
    slurp
    lsd
    zoxide
    avizo
    copyq
    udiskie
    gamemode
    #cava
    font-awesome
    #hyprshot
    gnome-tweaks
    gtk-engine-murrine
    gnome-themes-extra
    # devel
    xsecurelock
    #  xss-lock
    #  xdotool
    xclip

    wireshark-qt

    # cool irc client
    #    halloy

    #   dunst
    blueberry
    gparted
    direnv

    lunar-client
    neovide
    #proton-pass
    libreoffice-qt6-fresh
    youtube-music
    #direnv
    #powershell
    whatsapp-for-linux
    glow
    #swayimg
    microfetch
    yazi
    discordo
    corefonts
    teams-for-linux
    rose-pine-hyprcursor
    hyprpolkitagent
    gamemode
    networkmanagerapplet
    gammastep
    imv
    sbctl
    lowfi
    pavucontrol
    osu-lazer
    whitesur-icon-theme
    whitesur-gtk-theme
    whitesur-cursors
    whitesur-kde
    # gnome extensions
    gnomeExtensions.blur-my-shell
    gnomeExtensions.burn-my-windows
    gnomeExtensions.weather-or-not
    gnomeExtensions.rounded-window-corners-reborn
    gnomeExtensions.mpris-label
    gnomeExtensions.fly-pie
    gnomeExtensions.desktop-clock
    gnomeExtensions.dash-to-dock
  ];

  programs.librewolf.enable = false;
  programs.tmux.enable = true;

  # Add these environment variables to ensure themes are properly applied
  home.sessionVariables = {
    XCURSOR_THEME = "rose-pine-cursor";
    XCURSOR_SIZE = "24";
    #    NIXOS_OZONE_WL = "1";
  };
  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    EDITOR = "vim";
  };

  programs.git = {
    enable = true;
    userName = "jeebuscrossaint";
    userEmail = "thediamond270@gmail.com";
    extraConfig = {
      credental.helper = "store";
    };
  };

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    gitCredentialHelper.hosts = ["https://github.com"];
  };

  programs.gitui.enable = true;
  programs.feh.enable = false;
  programs.starship = {
    enable = true;
  };

  programs.fht-compositor = {
    enable = false;
  };

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  programs.cava.enable = false;
  programs.nh.enable = true;
  programs.qutebrowser.enable = false;
  programs.chromium.enable = false;
  programs.firefox.enable = false;
  programs.schizofox.enable = true;
  programs.zathura.enable = true;
  services.avizo.enable = true;
  services.tldr-update.enable = true;
  /*
  stylix.autoEnable = true;

  stylix.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-light.yaml";
  stylix.polarity = "dark";

  stylix.fonts = {
    serif = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrains Mono Nerd Font";
    };

    sansSerif = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrains Mono Nerd Font";
    };

    monospace = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrains Mono Nerd Font";
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

  stylix.cursor = {
    name = "whitesur-cursors";
    package = pkgs.whitesur-cursors;
    size = 24;
  };
  */

  stylix.targets.gtk.enable = true;
  /*
  stylix.iconTheme = {
    enable = true;
    package = pkgs.whitesur-icon-theme;
    dark = "Whitesur-icons";
    light = "Whitesur-icons";
  };

  stylix.opacity.terminal = 1.0; # LOL
  stylix.opacity.popups = 1.0;
  stylix.opacity.applications = 1.0;
  stylix.opacity.desktop = 1.0;
  */
}
