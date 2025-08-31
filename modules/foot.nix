{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.foot = {
    enable = true;
    settings = {
      main = {
        letter-spacing = 0;
        horizontal-letter-offset = 0;
        vertical-letter-offset = 0;
        pad = "40x40";
      };

      cursor = {
        style = "beam";
      };

      environment = {};

      security = {};

      bell = {};

      "desktop-notifications" = {};

      scrollback = {};

      url = {};

      mouse = {};

      touch = {};

      colors = {};

      csd = {};

      "key-bindings" = {};

      "search-bindings" = {};

      "url-bindings" = {};

      "text-bindings" = {};

      "mouse-bindings" = {};
    };
  };
}
