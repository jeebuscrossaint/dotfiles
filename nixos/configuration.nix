# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{
  config,
  pkgs,
  inputs,
  options,
  lib,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  system.stateVersion = "25.11";
  networking.hostName = "nixos";
  time.timeZone = "America/New_York";

 
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    tmp.useTmpfs = true;
    plymouth.enable = true;
  };

 
  # Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # NVIDIA
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };

  
  networking.networkmanager.enable = true;
  services.openssh.enable = true;
  services.tailscale.enable = true;

  services.xserver.windowManager.i3.enable = true;
  services.displayManager.gdm.enable = true;
  services.xserver.enable = true;
  # services.xserver.desktopManager.enlightenment.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;
  services.gnome.gnome-keyring.enable = false;

    environment.gnome.excludePackages = with pkgs; [
    atomix # puzzle game
    cheese # webcam tool
    evince # document viewer
    geary # email reader
    gedit # text editor
    gnome-characters
    gnome-music
    gnome-photos
    gnome-terminal
    gnome-tour
    hitori # sudoku game
    iagno # go game
    tali # poker game
    totem # video player
    gnome-contacts
    gnome-calendar
    yelp
    gnome-maps
    gnome-calculator
    gnome-system-monitor
    simple-scan
    gnome-clocks
    gnome-font-viewer
    file-roller
    epiphany
    seahorse
    gnome-logs
    gnome-connections
    gnome-text-editor
    gnome-weather
    gnome-software
    gnome-extension-manager
    rygel
    gnome-color-manager
#    gnome-console
  ];


  # Printing & Discovery
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.smartd.enable = true;

 
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  
  users.users.amarnath = {
    isNormalUser = true;
    description = "amarnath";
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [ ];
  };

  services.getty.autologinUser = "amarnath";


  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    max-jobs = "auto";
    cores = 0;
  };

  # Garbage Collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Auto Upgrade
  system.autoUpgrade = {
    enable = true;
    flake = "path:/home/amarnath/dotfiles/nixos";
    flags = [
      "--update-input"
      "nixpkgs"
    ];
    dates = "daily";
    allowReboot = false;
  };

  nixpkgs.config.allowUnfree = true;


  # Systemd
  systemd.settings.Manager = {
    RebootWatchdogSec = "0";
    KExecWatchdogSec = "0";
  };

  # Performance
  services.fstrim.enable = true;
  services.tuned.enable = true;

  # zRAM Swap
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # File Indexing
  services.locate = {
    enable = true;
    package = pkgs.plocate;
    interval = "hourly";
  };

  # Firmware Updates
  services.fwupd.enable = true;
 
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    config.common.default = "*";
  };

  security.polkit.enable = true;


  # Shell
  programs.fish.enable = true;

  # Gaming
  programs.gamemode.enable = true;
  # programs.steam = {
    # enable = true;
    # remotePlay.openFirewall = true;
    # dedicatedServer.openFirewall = true;
    # gamescopeSession.enable = true;
  # };

  # Flatpak
  services.flatpak = {
    enable = true;
    packages = [
      "org.vinegarhq.Sober"
    ];
    update.onActivation = true;
  };

  # Compatibility
  programs.nix-ld.enable = true;


  environment.systemPackages = with pkgs; [
    # Add your packages here
  ];
}
