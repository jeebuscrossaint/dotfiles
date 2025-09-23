{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./modules/newsboat.nix
    #./modules/bspwm.nix
    #    ./modules/sxhkd.nix
    # ./modules/fish.nix
    # ./modules/newsboat.nix
    #    ./modules/alacritty.nix
    #./modules/ashell.nix
    ./modules/bat.nix
    ./modules/foot.nix
    # ./modules/tealdeer.nix
    #./modules/bottom.nix
    ./modules/helix.nix
    ./modules/hyprlock.nix
    ./modules/fd.nix
    ./modules/btop.nix
    ./modules/rofi.nix
    #    ./modules/kitty.nix
    #./modules/mangohud.nix
    #./modules/micro.nix
    ./modules/mpv.nix
    #./modules/waybar.nix
    # ./modules/hyprland.nix
    #./modules/spectrwm.nix
    # ./modules/swaylock.nix
    ./modules/dunst.nix
    #./modules/fnott.nix
    # ./modules/sway.nix
    # ./modules/sway-fix.nix
    ./modules/hypridle.nix
    #./modules/picom.nix
    #./modules/i3.nix
    ./modules/vscode.nix
    # ./modules/nvf.nix
    # ./modules/fuzzel.nix
    #./modules/zed.nix
    # ./modules/hyprpaper.nix
    #    ./modules/fht.nix
    # ./modules/twmn.nix
    ./modules/bemenu.nix
    #    ./modules/i3status-rust.nix
    ./modules/nixcord.nix
    # ./modules/i3-fix.nix
    #./modules/nushell.nix
    # ./modules/bash.nix
    # ./modules/spicetify.nix
    ./modules/chawan.nix
    #    ./modules/emacs.nix
    ./modules/zsh.nix
    ./modules/river.nix
    # ./modules/ncspot.nix
    # ./modules/spotify-player.nix
  ];

  home.username = "amarnath";
  home.homeDirectory = "/home/amarnath";

  xresources.properties = {
  };

  home.packages = with pkgs; [
    vulkan-tools
    vulkan-loader
    vulkan-validation-layers
    vulkan-extension-layer
    libnotify
    xwallpaper
    bc
    swww
        pcmanfm
        standardnotes
    guvcview
    #unclutter
    shotman
    hyprshot
    hyprpicker
    libsecret
    wlay
    youtube-music
    #xsecurelock
    #flameshot
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
        # swayrbar
    autotiling-rs
    ipfetch
    wl-clipboard-rs
    slurp
    lsd
    #zoxide
    avizo
    cliphist
    udiskie
    gamemode
    font-awesome
    gnome-tweaks
    gtk-engine-murrine
    gnome-themes-extra
    xclip
    wireshark
    blueberry
    gparted
    lunar-client
    libreoffice-qt6-fresh
    #powershell
    whatsapp-for-linux
    glow
    # microfetch
    pfetch-rs
    yazi
    corefonts
    # rose-pine-hyprcursor
    # hyprpolkitagent
    gamemode
    imv
    sbctl
    lowfi
    pavucontrol
    tor-browser
    whitesur-icon-theme
    whitesur-gtk-theme
    whitesur-cursors
    rose-pine-cursor
    rose-pine-icon-theme
    rose-pine-gtk-theme
    # gnome extensions
    gnomeExtensions.blur-my-shell
       gnomeExtensions.burn-my-windows
       gnomeExtensions.weather-or-not
       gnomeExtensions.rounded-window-corners-reborn
       gnomeExtensions.mpris-label
       gnomeExtensions.fly-pie
       gnomeExtensions.desktop-clock
       gnomeExtensions.dash-to-dock
       gnomeExtensions.paperwm
  ];

  programs.librewolf.enable = true;
  programs.tmux.enable = true;

  # Add these environment variables to ensure themes are properly applied
  home.sessionVariables = {
    XCURSOR_THEME = "rose-pine-cursor";
    XCURSOR_SIZE = "24";
    NIXOS_OZONE_WL = "1";
  };
  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    EDITOR = "hx";
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

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  programs.cava.enable = true;
  programs.nh.enable = true;
  programs.qutebrowser.enable = false;
  programs.chromium.enable = false;
  programs.schizofox.enable = false;
  programs.zathura.enable = true;
  services.avizo.enable = true;

}
