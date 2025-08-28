{ config, pkgs, lib, ... }:
{
programs.bottom = {
	enable = false;
	settings = {
		flags = {
			temperature_type = "f";
			avg_cpu = true;
			group_processes = true;
		};
	};
};
}
