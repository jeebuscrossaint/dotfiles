{ config, pkgs, ... }:

{

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
	vesktop
	nix-search
	pywal16
	imagemagick
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

	adwaita-icon-theme
	gnome-tweaks
	sassc
	gtk-engine-murrine
	gnome-themes-extra
	# devel
	qemacs
	yazi

	wireshark-qt

	# cool irc client
	halloy
	];

gtk = {
	      enable = true;
	      
	    #  theme = {
	    #    name = "rose-pine-gtk";  # This is the internal theme name
	    #    package = pkgs.rose-pine-gtk-theme;
	    #  };
	      
	      #cursorTheme = {
	      #  name = "rose-pine-cursor";  # This is the internal cursor theme name
	      #  package = pkgs.rose-pine-cursor;
	      #  size = 24;
	      #};
	      
	      iconTheme = {
	        name = "rose-pine-icon-theme";  # This is the internal icon theme name
	        package = pkgs.rose-pine-icon-theme;
	      };
	    };
	  
	    # Add these environment variables to ensure themes are properly applied
	    #home.sessionVariables = {
	    #  GTK_THEME = "rose-pine-gtk";
	    #  XCURSOR_THEME = "rose-pine-cursor";
	    #  XCURSOR_SIZE = "24";
	    #};
    #gtk.font.name = "Monaspice Ne Nerd Font Mono";
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

	programs.gitui.enable = true;

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

	#programs.rofi.package = builtins.removeAttrs pkgs.rofi-wayland ["override"];
	home.stateVersion = "24.11";

	programs.home-manager.enable = true;

	programs.rofi.enable = true;
	programs.cava.enable = true;
	programs.fuzzel.enable = true;
	programs.qutebrowser.enable = true;
	programs.mpv.enable = true;
	programs.chromium.enable = true;
	stylix.autoEnable = true;
	
	stylix.enable = true;
	stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/da-one-black.yaml";
	stylix.polarity = "dark";

	stylix.fonts = {
		    serif = {
		      package = pkgs.nerd-fonts.monaspace;
		      name = "MonaspiceNe Nerd Font";
		    };
		
		    sansSerif = {
		      package = pkgs.nerd-fonts.monaspace;
		      name = "MonaspiceNe Nerd Font";
		    };
		
		    monospace = {
		      package = pkgs.nerd-fonts.monaspace;
		      name = "MonaspiceNe Nerd Font";
		    };
		
		    emoji = {
		      package = pkgs.nerd-fonts.monaspace;
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
}

