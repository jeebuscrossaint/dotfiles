{ config, lib, pkgs, ... }:

{
  programs.micro = {
    enable = true;
    settings = {
      # Tab settings
      tabsize = 8;         # Set tab width to 8 spaces
      tabstospaces = false; # Use actual tabs, not spaces
      
      # Indentation settings
      autoindent = true;
      indentchar = "\t";   # Use tab character for indentation
      
      # Editor behavior
      savecursor = true;   # Remember cursor position when reopening files
      saveundo = true;     # Save undo history
      scrollmargin = 3;    # Scroll margin
      scrollspeed = 2;     # Scroll speed
      
      # UI settings
      colorcolumn = 0;     # No color column
      cursorline = true;   # Highlight the line with the cursor
      ruler = true;        # Show line numbers and column
      syntax = true;       # Enable syntax highlighting
      
      # Search settings
      ignorecase = false;  # Case-sensitive search
      smartpaste = true;   # Intelligently add indentation when pasting
      
      # File handling
      autoclose = true;    # Automatically close brackets and quotes
      autosave = 0;        # Disable autosave
      rmtrailingws = false; # Don't remove trailing whitespace on save
      
      # Mouse settings
      mouse = true;        # Enable mouse support
      
      # Status line
      statusline = true;   # Show status line
      
      # Plugin settings
      pluginchannels = [
        "https://raw.githubusercontent.com/micro-editor/plugin-channel/master/channel.json"
      ];
      
      # Various settings
      autosu = false;      # Don't automatically use sudo
      backup = true;       # Create backup files
      clipboard = "internal"; # Use internal clipboard
      diffgutter = true;   # Show diff in gutter
      encoding = "utf-8";  # Default encoding
      eofnewline = true;   # Add newline at end of file
      fastdirty = true;    # Fast way to determine if file is modified
      keepautoindent = true; # Keep autoindent when deleting lines
    };
  };
}
