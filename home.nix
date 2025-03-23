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
                ./modules/rofi.nix
                ./modules/kitty.nix
                #./modules/mangohud.nix
                ./modules/micro.nix
                ./modules/mpv.nix
                ./modules/waybar.nix
                ./modules/hyprland.nix
		./modules/spectrwm.nix
		./modules/swaylock.nix
		./modules/dunst.nix
		./modules/fnott.nix
		./modules/sway.nix
		./modules/hypridle.nix
		./modules/picom.nix
		./modules/i3.nix
		./modules/nixvim.nix
        ];

	home.username = "amarnath";
	home.homeDirectory = "/home/amarnath";

	xresources.properties = {};

	home.packages = with pkgs; [
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
	qemacs
	yazi

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
	];
	
	programs.librewolf.enable = true;
	#programs.fnott.enable = true;
	programs.zed-editor.enable = true;
	programs.tmux.enable = true;
	#programs.dunst.enable = true;
	programs.emacs.enable = true;

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

	home.stateVersion = "24.11";

	programs.home-manager.enable = true;

	programs.cava.enable = true;
	programs.fuzzel.enable = true;
	programs.qutebrowser.enable = true;
	programs.chromium.enable = true;
	
	services.avizo.enable = true;
	stylix.autoEnable = true;
	
	stylix.enable = true;
	stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/black-metal-marduk.yaml";
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

	stylix.iconTheme = {
		enable = true;
		package = pkgs.rose-pine-icon-theme;
		dark = "Rose-pine-moon";
		light = "Rose-pine-dawn";
	};

	stylix.targets.avizo.enable = true;
	
}

