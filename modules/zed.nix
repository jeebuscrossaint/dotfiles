{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.zed-editor = {
    enable = true;
    extraPackages = with pkgs; [
      rustfmt
      rust-analyzer
      clang-tools # Provides clangd
    ];

    userSettings = {
      # LSP settings for specific languages
      language_overrides = {
        rust = {
          formatter = "language_server"; # Use rust-analyzer's formatting
        };
        c = {
          lsp = "clangd"; # Explicitly set clangd for C files
        };
        cpp = {
          lsp = "clangd"; # Explicitly set clangd for C++ files
        };
      };
      
      assistant = {
      	default-model = {
      		provider = "github.com";
      		model = "claude-3-7-sonnet-latest";
      	};
      	
      	editor-model = {
      		provider = "github.com";
      		model = "claude-3-7-sonnet-latest";
      	};
      };
    };
  };
}
