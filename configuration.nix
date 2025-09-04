# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  options,
  lib,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Bootloader.
  #boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;
  systemd.watchdog.rebootTime = "0";
  systemd.watchdog.kexecTime = "0";

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  boot = {
    plymouth = {
      enable = false;
    };
    kernelPackages = pkgs.linuxPackages_hardened;

    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      #"quiet"
      #      "splash"
      "boot.shell_on_fail"
      "loglevel=5"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "nosmt"
      "init_on_alloc=1"
      "init_on_free=1"
      "slab_nomerge"
      "slab_debug=FZP"
      "page_alloc.shuffle=1"
      "randomize_kstack_offset=on"
      "pti=on"
      "stack_guard_gap=1024"
      "modules.sig_enforce=1"
      "vsyscall=none"
      "debugfs=off"
      "oops=panic"
      "spec_store_bypass_disable=on"
      "l1tf=full,force"
      "mds=full,nosmt"
      "tsx=off"
      "tsx_async_abort=full,nosmt"
      "rd.systemd.show_status=1"
      "systemd.loglevel=debug"
      "nvidia-drm.modeset=1"
    ];
  };

  console.font = "Lat2-Terminus16";

  boot.kernel.sysctl."kernel.unprivileged_userns_clone" = 1;
  boot.kernel.sysctl = {
    "random.trust_cpu" = 0;
    "random.trust_bootloader" = 0;
    "kernel.kptr_restrict" = 2; # Hide kernel pointers
    "kernel.dmesg_restrict" = 1; # Restrict dmesg
    "kernel.printk" = "3 3 3 3"; # Disable kernel logs to console
    "kernel.unprivileged_bpf_disabled" = 1; # Disable unprivileged BPF
    "kernel.kexec_load_disabled" = 1; # Disable kexec
    "kernel.sysrq" = 0; # Disable magic SysRq key
  };

  hardware.graphics = {
    enable = true;
  };
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # Modesetting is required for Wayland
    modesetting.enable = true;

    # Power management - usually better left disabled for laptops to avoid issues
    powerManagement.enable = false;

    # Fine-grained power management (only works on Turing or newer GPUs, which your RTX 4070 is)
    powerManagement.finegrained = false;

    # Open source kernel module - RTX 4070 is Ada Lovelace architecture, which is supported
    open = true;

    # Enable the Nvidia settings menu
    nvidiaSettings = true;

    # Force full composition pipeline to prevent screen tearing with picom
    forceFullCompositionPipeline = true;

    # Use the appropriate driver version
    # For RTX 4070 mobile (Ada Lovelace architecture), the stable driver is appropriate
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  nix.settings.auto-optimise-store = true;
  #nix.settings.max-jobs = 16;
  environment.sessionVariables = {
    # For all Wayland compositors
    #WLR_NO_HARDWARE_CURSORS = "1";

    # For Electron apps
    NIXOS_OZONE_WL = "1";

    # Force GBM backend for NVIDIA on Wayland
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";

    # For Vulkan applications
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json";
  };

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
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

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.amarnath = {
    isNormalUser = true;
    description = "amarnath";
    extraGroups = ["networkmanager" "wheel" "input" "wireshark"];
    packages = with pkgs; [];
  };

  # Enable automatic login for the user.
  services.getty.autologinUser = "amarnath";
  services.power-profiles-daemon.enable = true;
  services.supergfxd.enable = true;
  services.asusd.enable = true;
  services.asusd.enableUserService = true;
  services.tor = {
    enable = true;
    client.enable = true;
  };
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    inputs.zen-browser.packages."${system}".default
    #inputs.ewww.packages."${system}".default
    #    inputs.numlockwl.packages."${system}".default
    inputs.doomer.packages."${system}".default
    #inputs.limebar.packages."${system}".default
    #inputs.wart.packages."${system}".default
    #inputs.prismlauncher.packages."${system}".default
    #inputs.hyprpicker.packages."${system}".default
    #inputs.hyprpaper.packages."${system}".default
    #inputs.swayfx.packages."${system}".default
    #    inputs.xdg-desktop-portal-hyprland.packages."${system}".default
    #    inputs.hypridle.packages."${system}".default
    #inputs.quickemu.packages."${system}".default
    #inputs.quickgui.packages."${system}".default
    #inputs.nix-index.packages."${system}".default
    #inputs.swww.packages."${system}".default
    #    inputs.rose-pine-hyprcursor.packages."${system}".default
    #inputs.yazi.packages."${system}".default
    #    inputs.hyprpolkitagent.packages."${system}".default
    #inputs.conky.packages."${system}".default
    #inputs.helix.packages."${system}".default
    #inputs.waybar.packages."${system}".default
    inputs.aocli.packages."${system}".default
    #inputs.debt.packages."${system}".default
    #    inputs.quickshell.packages."${system}".default
    #    inputs.ironbar.packages."${system}".default
    inputs.sf-mono-nerd-font.packages."${system}".default
  ];

  services.logind.extraConfig = ''
    HandlePowerKey=ignore
  '';

  programs.sway = {
    enable = false;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [brightnessctl foot grim pulseaudio swayidle];
    package = pkgs.swayfx;
  };

  #  programs.fht-compositor = {
  #    enable = false;
  # package = fht-compositor.packages.${pkgs.system}.fht-compositor; # optional if default is okay
  #  };

  programs.nix-ld.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = pkgs.hyprland;
  };

  xdg.portal.enable = true;
  xdg.portal.wlr.enable = true;

  programs.fish.enable = true;
  security.polkit.enable = true;

  users.users.amarnath.shell = pkgs.fish; #nushell sometime?
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  networking.timeServers = options.networking.timeServers.default;
  virtualisation.virtualbox.host.enable = false;
  users.extraGroups.vboxusers.members = ["amarnath"];
  virtualisation.virtualbox.host.enableExtensionPack = false;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # Some random BS
  home-manager.backupFileExtension = "backup";

  services.xserver = {
    enable = true;
    desktopManager.xfce.enable = false;
    windowManager.i3.enable = false;
    windowManager.spectrwm.enable = false;
    displayManager.lightdm.enable = false;
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
    displayManager.sddm.enable = false;
  };

  services = {
    desktopManager.plasma6.enable = false;
  };

  services.libinput = {
    enable = true;

    mouse = {
      accelProfile = "flat";
    };

    touchpad = {
      accelProfile = "flat";
    };
  };

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
    gnome-console
  ];

  programs.xwayland.enable = true;

  location.provider = "geoclue2";
  services.gnome.gnome-keyring.enable = true;
  services.udev.packages = with pkgs; [gnome-settings-daemon];
  security.pam.services.hyprlock = {};
  services.flatpak.enable = true;
  services.flatpak.packages = [
    "org.vinegarhq.Sober"
  ];
  services.flatpak.update.onActivation = true;
  security.pam.services.gdm-password.enableGnomeKeyring = true;

  # potentially temporrary
  stylix.autoEnable = true;

  stylix.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/irblack.yaml";

  stylix.fonts = {
    serif = {
      package = inputs.sf-mono-nerd-font.packages."${pkgs.system}".default;
      name = "SFMono Nerd Font";
    };

    sansSerif = {
      package = inputs.sf-mono-nerd-font.packages."${pkgs.system}".default;
      name = "SFMono Nerd Font";
    };

    monospace = {
      package = inputs.sf-mono-nerd-font.packages."${pkgs.system}".default;
      name = "SFMono Nerd Font";
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

  stylix.opacity.terminal = 1.0; # LOL
  stylix.opacity.popups = 1.0;
  stylix.opacity.applications = 1.0;
  stylix.opacity.desktop = 1.0;
  /*
  stylix.iconTheme = {
    enable = true;
    package = pkgs.whitesur-icon-theme;
    dark = "Whitesur-icons";
    light = "Whitesur-icons";
  };
  */

  /*
  stylix.targets.gtk.enable = false;
  */

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
