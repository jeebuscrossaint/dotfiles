{ config, pkgs, ... }:

{
  programs.gnome-shell = {
    enable = true;

    extensions = [
      { package = pkgs.gnomeExtensions.blur-my-shell; }
      { package = pkgs.gnomeExtensions.impatience; }
      { package = pkgs.gnomeExtensions.appindicator }
    ];
  };

  dconf = {
  	enable = true;
  	settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };
}
