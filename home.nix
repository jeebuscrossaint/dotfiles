{
  config,
  pkgs,
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
    ./modules/nvf.nix
    ./modules/fuzzel.nix
    ./modules/zed.nix
    ./modules/hyprpaper.nix
  ];

  home.username = "amarnath";
  home.homeDirectory = "/home/amarnath";

  xresources.properties = {
  };

  home.pointerCursor.x11.enable = true;

  home.packages = with pkgs; [
  swaybg
  hyprpaper
    swaynotificationcenter
    cutter
    ghidra
    qalculate-gtk
    quickemu
    qemu_full
    qemu-user
    uefi-run
    i3status-rust
    fastfetch
    tree
    fzf
    which
    btop
    pciutils
    vesktop
    nix-search
    nix-index
    swayrbar
    pfetch-rs
    autotiling-rs
    autotiling
    ipfetch
    micro
    wl-clipboard-rs
    slurp
    lsd
    zoxide
    avizo
    # hyprland/sway-wayland stuff
    swww
    hypridle
    dunst
    copyq
    udiskie
    gamemode
    cava
    font-awesome
    flameshot
    hyprshot
    rose-pine-hyprcursor
    adwaita-icon-theme
    gnome-tweaks
    sassc
    gtk-engine-murrine
    gnome-themes-extra
    # devel
    yazi
    xsecurelock
    xss-lock
    xdotool
    xclip

    wireshark-qt

    # cool irc client
    halloy

    dunst
    blueberry
    gparted
    hyprpolkitagent

    lunar-client
    conky
    neovide
    proton-pass
    emacs-gtk
    libreoffice-qt6-fresh
    youtube-music
    osu-lazer
  ];

  programs.librewolf.enable = true;
  #programs.fnott.enable = true;
  programs.tmux.enable = true;
  #programs.dunst.enable = true;

  gtk = {
    enable = true;
  };

  # Add these environment variables to ensure themes are properly applied
  home.sessionVariables = {
    XCURSOR_THEME = "rose-pine-cursor";
    XCURSOR_SIZE = "24";
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

  programs.starship = {
    enable = true;
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
  };

  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  programs.cava.enable = true;
  programs.qutebrowser.enable = true;
  programs.chromium.enable = true;

  services.avizo.enable = true;
  stylix.autoEnable = true;

  stylix.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-soft.yaml";
  stylix.polarity = "dark";

  stylix.fonts = {
    serif = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font";
    };

    sansSerif = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font";
    };

    monospace = {
      package = pkgs.cozette;
      name = "Cozette";
    };

    emoji = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "Noto Color Emoji";
    };
  };

  stylix.fonts.sizes = {
    terminal = 11;
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
  
  stylix.opacity.terminal = 0.85;
  stylix.opacity.popups = 0.9;
  stylix.opacity.applications = 0.9;
  stylix.opacity.desktop = 0.9;

}
