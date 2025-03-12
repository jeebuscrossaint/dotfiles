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

	gnome-tweaks

	wireshark-qt
	];

gtk = {
	      enable = true;
	      
	      theme = {
	        name = "rose-pine-gtk";  # This is the internal theme name
	        package = pkgs.rose-pine-gtk-theme;
	      };
	      
	      cursorTheme = {
	        name = "rose-pine-cursor";  # This is the internal cursor theme name
	        package = pkgs.rose-pine-cursor;
	        size = 24;
	      };
	      
	      iconTheme = {
	        name = "rose-pine-icon-theme";  # This is the internal icon theme name
	        package = pkgs.rose-pine-icon-theme;
	      };
	    };
	  
	    # Add these environment variables to ensure themes are properly applied
	    home.sessionVariables = {
	      GTK_THEME = "rose-pine-gtk";
	      XCURSOR_THEME = "rose-pine-cursor";
	      XCURSOR_SIZE = "24";
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
