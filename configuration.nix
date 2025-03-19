# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot = {
  	
  	plymouth = {
  		enable = true;
  	};
  	
  	consoleLogLevel = 0;
  	initrd.verbose = false;
  	kernelParams = [
  		"quiet"
  		"splash"
  		"boot.shell_on_fail"
  		"loglevel=3"
  		"rd.systemd.show_status=false"
  		"rd.udev.log_level=3"
  		"udev.log_priority=3"
  	];
  	
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
    extraGroups = [ "networkmanager" "wheel" "input" "wireshark" ];
    packages = with pkgs; [];
  };

  # Enable automatic login for the user.
  services.getty.autologinUser = "amarnath";
  services.power-profiles-daemon.enable = true;
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  wget
  git
  inputs.zen-browser.packages."${system}".default
  inputs.ewww.packages."${system}".default
  ];

  fonts.packages = with pkgs; [
  nerd-fonts.monaspace
  ];

  programs.sway = {
	enable = true;
	wrapperFeatures.gtk = true;
  	extraPackages = with pkgs; [ brightnessctl foot grim pulseaudio swayidle ];
  };

  programs.hyprland = {
  	enable = true;
  	xwayland.enable = true;
  	package = inputs.hyprland.packages."${pkgs.system}".hyprland;
  };
  
  programs.fish.enable = true;
  security.polkit.enable = true;

  users.users.amarnath.shell = pkgs.fish;
  security.rtkit.enable = true;
  services.pipewire = {
	enable = true;
	alsa.enable = true;
	alsa.support32Bit = true;
	pulse.enable = true;
	jack.enable = true;
   };

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
  	displayManager.gdm.enable = true;
  	desktopManager.gnome.enable = true;
  };

  environment.gnome.excludePackages = (with pkgs; [
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
  ]);

  services.udev.packages = with pkgs; [ gnome-settings-daemon ];
  security.pam.services.hyprlock = {};
  services.flatpak.enable = true;
 security.pam.services.gdm-password.enableGnomeKeyring = true;
   
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

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
  system.stateVersion = "24.11"; # Did you read the comment?

}
