{
  config,
  pkgs,
  inputs,
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
  ];

  home.username = "amarnath";
  home.homeDirectory = "/home/amarnath";

  xresources.properties = {
  };

  home.pointerCursor.x11.enable = true;

  home.packages = with pkgs; [
    wlay
    swaybg
    swaynotificationcenter
    cutter
    ghidra
    qalculate-gtk
    qemu_full
    qemu-user
    fastfetch
    tree
    fzf
    which
    btop
    pciutils
    #vesktop
    swayrbar
    pfetch-rs
    autotiling-rs
    autotiling
    ipfetch
    wl-clipboard-rs
    slurp
    lsd
    zoxide
    avizo
    copyq
    udiskie
    gamemode
    cava
    font-awesome
    hyprshot
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

    lunar-client
    #    neovide
    proton-pass
    libreoffice-qt6-fresh
    youtube-music
    nix-search
    direnv
    powershell
    whatsapp-for-linux
    tor-browser
    glow
    swayimg

    # gnome extensions
    #gnomeExtensions.blur-my-shell
    #gnomeExtensions.burn-my-windows
    #gnomeExtensions.weather-or-not
    #gnomeExtensions.rounded-window-corners-reborn
    #gnomeExtensions.mpris-label
    #gnomeExtensions.fly-pie
    #gnomeExtensions.desktop-clock
  ];

  programs.librewolf.enable = false;
  programs.tmux.enable = true;

  # Add these environment variables to ensure themes are properly applied
  home.sessionVariables = {
    XCURSOR_THEME = "rose-pine-cursor";
    XCURSOR_SIZE = "24";
    NIXOS_OZONE_WL = "1";
  };
  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    EDITOR = "micro";
  };

  programs.git = {
    enable = true;
    userName = "jeebuscrossaint";
    userEmail = "thediamond270@gmail.com";
    extraConfig = {
      credental.helper = "store";
    };
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    gitCredentialHelper.hosts = ["https://github.com"];
  };

  programs.gitui.enable = true;
  programs.feh.enable = true;
  programs.starship = {
    enable = true;
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
  };

  programs.fht-compositor = {
    enable = true;
  };

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  programs.cava.enable = true;
  programs.qutebrowser.enable = false;
  programs.chromium.enable = true;
  programs.firefox.enable = true;
  services.avizo.enable = true;
  services.tldr-update.enable = true;
  stylix.autoEnable = true;

  stylix.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/bright.yaml";
  stylix.polarity = "dark";

  stylix.fonts = {
    serif = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "Fira Mono Nerd Font";
    };

    sansSerif = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "Fira Mono Nerd Font";
    };

    monospace = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "Fira Mono Nerd Font";
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
    name = "rose-pine-cursor";
    package = pkgs.rose-pine-cursor;
    size = 24;
  };

  stylix.iconTheme = {
    enable = true;
    package = pkgs.rose-pine-icon-theme;
    dark = "Rose-pine-moon";
    light = "Rose-pine-dawn";
  };

  stylix.opacity.terminal = 1.0; # LOL
  stylix.opacity.popups = 1.0;
  stylix.opacity.applications = 1.0;
  stylix.opacity.desktop = 1.0;
}
