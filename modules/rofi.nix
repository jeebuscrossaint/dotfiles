{ config, lib, pkgs, ... }:

{
  programs.rofi = {
    enable = false;
    
    # Basic configuration
    extraConfig = {
      show-icons = true;
      display-drun = "";
      drun-display-format = "{name}";
      disable-history = false;
      fullscreen = false;
      hide-scrollbar = true;
      sidebar-mode = false;
    };
    
    # Theme configuration
    theme = let
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "window" = {
        border = mkLiteral "1";
        padding = mkLiteral "5";
        width = mkLiteral "30%";
        height = mkLiteral "40%";
      };
      
      "inputbar" = {
        children = map mkLiteral [ 
          "textbox-prompt-colon" 
          "entry" 
          "num-filtered-rows" 
          "textbox-num-sep" 
          "num-rows" 
          "case-indicator" 
        ];
        border = mkLiteral "0 0 1px 0";
        padding = mkLiteral "5px";
      };
      
      "prompt" = {
        padding = mkLiteral "5px 5px 0px";
      };
      
      "entry" = {
        padding = mkLiteral "5px";
      };
      
      "listview" = {
        lines = 8;
        columns = 1;
        "fixed-height" = mkLiteral "0";
        border = mkLiteral "1px 0 0 0";
        spacing = mkLiteral "5px";
        scrollbar = false;
        padding = mkLiteral "5px 5px 0px";
      };
      
      "element" = {
        border = mkLiteral "0";
        padding = mkLiteral "5px";
      };
      
      "element-text" = {
        "background-color" = mkLiteral "inherit";
        "text-color" = mkLiteral "inherit";
      };
      
      /* Styles for Rofi calc */
      "textbox-prompt-colon" = {
        expand = false;
        str = ":";
        margin = mkLiteral "0px 0.3em 0em 0em";
      };
      
      "num-filtered-rows, num-rows" = {
        "text-color" = mkLiteral "inherit";
      };
      
      "textbox-num-sep" = {
        expand = false;
        str = "/";
      };
      
      /* Style for the result field in Rofi calc */
      "textbox" = {
        padding = mkLiteral "8px";
      };
    };
  };
}
