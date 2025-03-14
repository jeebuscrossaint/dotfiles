{ config, pkgs, lib, ... }:
{
programs.bottom = {
	enable = true;
	settings = {
		flags = {
			temperature_type = "f";
			avg_cpu = true;
			group_processes = true;
		};
	};
};
}
