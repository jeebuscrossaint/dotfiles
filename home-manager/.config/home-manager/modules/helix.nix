{ config, lib, pkgs, ... }:
{

programs.helix = {
  enable = true;
  # # package = pkgs.emptyDirectory;
  settings = {
    editor = {
      line-number = "relative";
      cursorline = true;
      color-modes = true;
      bufferline = "always";
      cursor-shape = {
        insert = "bar";
        normal = "block";
        select = "underline";
      };
      # Indentation settings
      indent-guides.render = true;
      indent-guides.character = "│";  # Vertical line for indent guides
      soft-wrap.enable = true;
    };
    
    keys = {
      normal = {
        # Some helpful keybindings
        "space" = {
          "space" = "file_picker";
          "w" = ":w";
          "q" = ":q";
          "f" = "file_picker_in_current_directory";
          #"/" = "search_in_buffer";
        };
        # Quick buffer navigation
        "C-n" = "goto_next_buffer";
        "C-p" = "goto_previous_buffer";
      };
      insert = {
        # Easy way to exit insert mode
        "C-c" = "normal_mode";
      };
    };
  };
  
  languages = {
    language-server = {
      # Define language servers here if needed
    };
    language = [
      # Language specific settings
      {
        name = "rust";
        auto-format = true;
        formatter = { command = "rustfmt"; };
      }
      {
        name = "nix";
        auto-format = true;
      }
      {
      	name = "c";
      	auto-format = true;
      	formatter = { command = "clangd"; };
      }
      { 
        name = "cpp";
        auto-format = true;
        formatter = { command = "clangd"; };
      }
    ];
  };
  
  # Ignore patterns for file picker
  ignores = [
    ".git/"
    "target/"
    "node_modules/"
    "dist/"
  ];
};
}
