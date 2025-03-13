{ config, lib, pkgs, ... }:

{
  programs.foot = {
    enable = true;
    settings = {
      main = {
#        include = "~/.cache/wal/colors-foot.ini";
#        font = "Monaspice Ne Nerd Font:size=10";
        letter-spacing = 0;
        horizontal-letter-offset = 1;
        vertical-letter-offset = 1;
      };
      
      cursor = {
        style = "beam";
      };
      
      environment = { };
      
      security = { };
      
      bell = { };
      
      "desktop-notifications" = { };
      
      scrollback = { };
      
      url = { };
      
      mouse = { };
      
      touch = { };
      
      colors = { };
      
      csd = { };
      
      "key-bindings" = { };
      
      "search-bindings" = { };
      
      "url-bindings" = { };
      
      "text-bindings" = { };
      
      "mouse-bindings" = { };
    };
  };
}
