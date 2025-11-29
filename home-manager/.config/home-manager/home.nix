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
    # ./modules/bemenu.nix
    ./modules/nixcord.nix
    ./modules/chawan.nix
     ./modules/sway.nix
     ./modules/fish.nix
     ./modules/swaylock.nix
     ./modules/rofi.nix
     ./modules/swayidle.nix
     ./modules/sway-fix.nix
     ./modules/labwc.nix
     ./modules/zed.nix
     ./modules/yazi.nix
     # ./modules/wayfire.nix
     ./modules/kitty.nix
     ./modules/nvf.nix
     ./modules/i3.nix
     ./modules/i3-fix.nix
     # ./modules/xmonad.nix
     # ./modules/awesome.nix
     # ./modules/spectrwm.nix
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
    wget
    dosfstools
    bottom
    qemu
    xterm
    xorg.xrandr
    # xsecurelock
    flameshot
    autotiling
    # virtualboxWithExtpack
    bc
    swww
    hollywood
    cmatrix
    cbonsai
    pipes-rs
    # pcmanfm
    gdu
    steam
    standardnotes
    # guvcview
    shotman
    less
    # hyprshot
    hyprpicker
    htop
    # libsecret
    # wlay
    wlsunset
    youtube-music
    tinycc
    nixfmt
    typstyle
    typst
    typst-live
    dotnet-sdk
    cutter
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
    pfetch-rs
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
    # gparted
    lunar-client
    libreoffice-fresh
    wasistlos
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
    # guvcview
    # cheese
    snapshot
    brightnessctl
    rustup
    # rustfmt
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
    # inputs.drawy.packages."${pkgs.system}".default
    inputs.sway-alttab-flake.packages."${pkgs.system}".default
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
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/kimber.yaml";
  
  # stylix.base16Scheme = "${pkgs.writeTextFile {
  #  name = "hacker-green-scheme";
  #  text = ''
  #    name: "Hacker Green"
  #    slug: hacker-green
  #    author: "Amarnath Patel apatel6ty@protonmail.com"
  #    variant: "dark"
  #    palette:
  #      base00: "#000000"  # black (background)
  #      base01: "#003300"  # dark green (lighter background, status bars)
  #      base02: "#006600"  # medium green (selection background)
  #      base03: "#009900"  # bright green (comments, invisibles, line highlighting)
  #      base04: "#00cc00"  # light green (dark foreground, used for status bars)
  #      base05: "#33ff33"  # green (default foreground, caret, delimiters, operators)
  #      base06: "#66ff66"  # light green (light foreground)
  #      base07: "#99ff99"  # very light green (lightest foreground)
  #      base08: "#ff3333"  # red (error highlighting, diff removed)
  #      base09: "#ff9933"  # orange (integers, booleans, constants)
  #      base0A: "#ffff33"  # yellow (keywords, search text)
  #      base0B: "#33ff33"  # green (strings, inherited classes)
  #      base0C: "#66ff66"  # cyan (support, regex, escape characters)
  #      base0D: "#33cc33"  # blue (functions, methods, attribute ids)
  #      base0E: "#99cc99"  # purple (storage, selectors, markup italics)
  #      base0F: "#cc6666"  # brown (deprecated elements, embedded language tags)
  #    '';
  #  }}";
    stylix.fonts = {
    serif = {
      # package = inputs.sf-mono-nerd-font.packages."${pkgs.system}".default;
      # name = "SFMono Nerd Font";
      package = pkgs.spleen;
      name = "Spleen 16x32";
    };
    sansSerif = {
      # package = inputs.sf-mono-nerd-font.packages."${pkgs.system}".default;
      # name = "SFMono Nerd Font";
package = pkgs.spleen;
      name = "Spleen 16x32";
    };
    monospace = {
      # package = inputs.sf-mono-nerd-font.packages."${pkgs.system}".default;
      # name = "SFMono Nerd Font";
package = pkgs.spleen;
      name = "Spleen 16x32";
    };
    emoji = {
      package = pkgs.noto-fonts-color-emoji;
      name = "Noto Color Emoji";
    };
  };

  stylix.fonts.sizes = {
    terminal = 13.5;
    desktop = 13.5;
    applications = 13.5;
    popups = 13.5;
  };

  stylix.opacity.terminal = 0.5;
  stylix.opacity.popups = 1.0;
  stylix.opacity.applications = 1.0;
  stylix.opacity.desktop = 1.0;
}
