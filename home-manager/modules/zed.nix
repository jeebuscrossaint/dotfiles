{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "toml"
      "make"
      "typst"
    ];
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
      # Enable autosave
      autosave = "on_focus_change";
      
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

      # Default to Claude Sonnet 4.5
      assistant = {
        enabled = true;
        version = "2";
        default_open_ai_model = null;
        default_model = {
          provider = "copilot_chat";
          model = "claude-sonnet-4-5";
        };
      };

      # Also set for inline assistant
      inline_assistant = {
        enabled = true;
        default_model = {
          provider = "copilot_chat";
          model = "claude-sonnet-4-5";
        };
      };

      node = {
        path = lib.getExe pkgs.nodejs;
        npm_path = lib.getExe' pkgs.nodejs "npm";
      };
    };
  };
}
