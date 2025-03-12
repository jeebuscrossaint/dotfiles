{ config, pkgs, ... }:

{

        imports = [
                ./modules/fish.nix
                ./modules/alacritty.nix
                ./modules/bat.nix
                ./modules/foot.nix
                ./modules/tealdeer.nix
        ];

	home.username = "amarnath";
	home.homeDirectory = "/home/amarnath";

	xresources.properties = {};

	home.packages = with pkgs; [
	fastfetch
	tree
	fzf
	which
	btop
	pciutils
	rofi-wayland
	vesktop
	nix-search
	pywal16
	imagemagick
	chromium
	swayrbar
	pfetch-rs
	autotiling-rs
	ipfetch
	micro
	wl-clipboard-rs
	slurp
	lsd
	zoxide
	avizo
	fuzzel
	tofi
	# gtk styles n stuff
	#rose-pine-cursor
	#rose-pine-icon-theme
	#rose-pine-gtk-theme
	#whitesur-cursors
	#whitesur-icon-theme
	#whitesur-gtk-theme
	# hyprland/sway-wayland stuff
	hypridle
	dunst
	copyq
	udiskie
	gamemode
	waybar
	cava
	font-awesome
	flameshot
	hyprshot
	swaylock-effects

	# devel
	qemacs

	wireshark-qt
	];

	# Enable GTK configuration
	  gtk.enable = true;
	
	  # Set GTK theme to Rose Pine
	  gtk.theme = {
	    name = "Rose-Pine";
	    package = pkgs.rose-pine-gtk-theme; # You may need to check the exact package name
	  };
	
	  # Set cursor theme to Rose Pine
	  gtk.cursorTheme = {
	    name = "Rose-Pine-Cursor"; # Check the exact cursor theme name
	    package = pkgs.rose-pine-cursor; # You may need to check the exact package name
	    size = 24; # Adjust size as needed
	  };
	
	  # Set icon theme to Rose Pine
	  gtk.iconTheme = {
	    name = "Rose-Pine-Icons"; # Check the exact icon theme name
	    package = pkgs.rose-pine-icon-theme; # You may need to check the exact package name
	  };
    gtk.font.name = "Monaspice Ne Nerd Font Mono";
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
	        gitCredentialHelper.hosts = [ "https://github.com" ];
	};

	programs.starship = {
	enable = true;
	};

	programs.alacritty = {
	enable = true;
	};

	programs.bash = {
	enable = true;
	enableCompletion = true;
	};

	programs.rofi.package = builtins.removeAttrs pkgs.rofi-wayland ["override"];
	home.stateVersion = "24.11";

	programs.home-manager.enable = true;


	# Fish BS
	
}
