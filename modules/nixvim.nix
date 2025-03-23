{
	programs.nixvim = {
		enable = true;
		
		opts = {
			number = true;
			shadafile = "NONE";
			timeout = true;
			timeoutlen = 300;
			ttimeoutlen = 10;
			updatetime = 250;
			completeopt = "menu,menuone,noinsert";
		};
		
		performance = {
			byteCompileLua.enable = true;
			byteCompileLua.configs = true;
			byteCompileLua.initLua = true;
			byteCompileLua.nvimRuntime = true;
			byteCompileLua.plugins = true;
			# Experimental can break any build
			# combinePlugins.enable = true;
		};
		
		clipboard = {
			providers.wl-copy.enable = true;
			providers.xclip.enable = true;
		};
		
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
		
		plugins.zig = {
			enable = true;
		};
		
		plugins.zen-mode = {
			enable = true;
		};
		
		plugins.yazi = {
			enable = true;
		};
		
		plugins.which-key = {
			enable = true;
		};
		
		plugins.vimtex = {
			enable = true;
		};
		
		plugins.treesitter = {
			enable = true;
		};
		
		plugins.telescope = {
			enable = true;
		};
		
		plugins.rainbow-delimiters = {
			enable = true;
		};
		
		plugins.quicker = {
			enable = true;
		};
		
		plugins.nui = {
			enable = true;
		};
		
		plugins.mini = {
			enable = true;
		};
		
		plugins.markdown-preview = {
			enable = true;
		};
		
		plugins.lsp = {
			enable = true;
			autoLoad = true;
		};
		
		plugins.hex = {
			enable = true;
		};
		
		plugins.fzf-lua = {
			enable = true;
		};
		
		plugins.floaterm = {
			enable = true;
		};
		
		plugins.cursorline = {
			enable = true;
		};
		
		plugins.copilot-chat = {
			enable = true;
			settings = {
				model = "claude-3.5-sonnet";
			};
		};
		
		plugins.copilot-cmp = {
			enable = true;
		};
		
		plugins.commentary = {
			enable = true;
		};
		
		plugins.cmp = {
			enable = true;
			settings = {
			sources = [
				{ name = "nvim_lsp"; }
				{ name = "buffer"; }
				{ name = "path"; }
			];
			};
		};
		
		plugins.luasnip.enable = true;
	
		plugins.neo-tree = {
			enable = true;
		};
		
		plugins.colorizer = {
			enable = true;
		};
		
		plugins.cmp-path = {
			enable = true;
		};
		
		plugins.fidget = {
			enable = true;
		};
		
	};
}
