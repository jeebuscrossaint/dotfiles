{ config, lib, pkgs, ... }:

{
	programs.tealdeer = {
		enable = false;
		settings = {
			display = {
				compact = false;
				use_pager = true;
			};

		updates = {
			auto_update = true;
			auto_update_interval_hours = 24;
			};
		};
	};
}
