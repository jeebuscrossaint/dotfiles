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

  # ============================================================================
  # System Configuration
  # ============================================================================

  system.stateVersion = "25.11";
  networking.hostName = "nixos";
  time.timeZone = "America/New_York";

  # ============================================================================
  # Boot Configuration
  # ============================================================================

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    tmp.useTmpfs = true;
    plymouth.enable = true;
  };

  # ============================================================================
  # Hardware Configuration
  # ============================================================================

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

  # ============================================================================
  # Networking
  # ============================================================================

  networking.networkmanager.enable = true;
  services.openssh.enable = true;
  services.tailscale.enable = true;

  # Printing & Discovery
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # ============================================================================
  # Localization
  # ============================================================================

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

  # ============================================================================
  # Audio
  # ============================================================================

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # ============================================================================
  # User Configuration
  # ============================================================================

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

  # ============================================================================
  # Nix Configuration
  # ============================================================================

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

  # ============================================================================
  # System Services & Optimization
  # ============================================================================

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

  # ============================================================================
  # Desktop Environment & Portal
  # ============================================================================

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    config.common.default = "*";
  };

  security.polkit.enable = true;

  # ============================================================================
  # Programs & Applications
  # ============================================================================

  # Shell
  programs.fish.enable = true;

  # Gaming
  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

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

  # ============================================================================
  # System Packages
  # ============================================================================

  environment.systemPackages = with pkgs; [
    # Add your packages here
  ];
}
