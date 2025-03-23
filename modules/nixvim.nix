{
	programs.nixvim = {
		enable = true;
		plugins.lualine.enable = true;
		
		plugins.copilot-lua = {
			enable = true;
			settings = {
				panel = {
					enabled = true;
					auto_refresh = true;
				};
				suggestion.enabled = true;
			};
		};
	};
}
