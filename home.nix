{ config, pkgs, ... }:

{
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
	rofi-wayland-unwrapped
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
	rose-pine-cursor
	rose-pine-icon-theme
	rose-pine-gtk-theme

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
	gh
	];

	gtk.enable = true;
        gtk.theme.name = "rose-pine-gtk";
        gtk.iconTheme.name = "rose-pine-icons";
        gtk.cursorTheme.name = "rose-pine-cursor";
	programs.git = {
	enable = true;
	userName = "jeebuscrossaint";
	userEmail = "thediamond270@gmail.com";
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

	programs.rofi.package = builtins.removeAttrs pkgs.rofi-unwrapped ["override"];
	home.stateVersion = "24.11";

	programs.home-manager.enable = true;
}
