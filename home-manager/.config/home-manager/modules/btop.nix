{ config, lib, pkgs, ... }:
{
programs.btop = {
	enable = true;
	package = pkgs.emptyDirectory;
	settings = {
		temp_scale = "fahrenheit";
		update_ms = 100;
	};
};
}
