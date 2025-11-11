{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.zed-editor = {
    enable = true;
    extensions = ["nix" "toml" "make"];
    extraPackages = with pkgs; [
      rustfmt
      rust-analyzer
      clang-tools # Provides clangd
      nixd
      nil
      gopls
      go
    ];

    userSettings = {
      # LSP settings for specific languages
      language_overrides = {
        rust = {
          formatter = "language_server"; # Use rust-analyzer's formatting
          lsp = "rust-analyzer";
        };
        c = {
          lsp = "clangd"; # Explicitly set clangd for C files
        };
        cpp = {
          lsp = "clangd"; # Explicitly set clangd for C++ files
        };
      };

      assistant = {
        enabled = true;
        version = "2";
        default_open_ai_model = null;
        ### PROVIDER OPTIONS
        ### zed.dev models { claude-3-5-sonnet-latest } requires github connected
        ### anthropic models { claude-3-5-sonnet-latest claude-3-haiku-latest claude-3-opus-latest  } requires API_KEY
        ### copilot_chat models { gpt-4o gpt-4 gpt-3.5-turbo o1-preview } requires github connected
        default_model = {
          provider = "copilot_chat";
          model = "claude-3-7-sonnet";
        };

        #                inline_alternatives = [
        #                    {
        #                        provider = "copilot_chat";
        #                        model = "gpt-3.5-turbo";
        #                    }
        #                ];
      };

      node = {
        path = lib.getExe pkgs.nodejs;
        npm_path = lib.getExe' pkgs.nodejs "npm";
      };
    };
  };
}
