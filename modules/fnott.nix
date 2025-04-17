{ config, lib, pkgs, ... }:

{
  services.fnott = {
    enable = false;
    package = pkgs.fnott;
    settings = {
      main = {
        # General settings
        output = ""; # Empty to show on all outputs
        min-width = 300;
        max-width = 500;
        max-height = 400;
        stacking-order = "top-down";
        anchor = "top-right";
        notification-margin = 10;
        margin-top = 10;
        margin-right = 10;
        margin-bottom = 10;
        margin-left = 10;
        max-icon-size = 32;
        icon-spacer = 8;
        sort-by = "time";
        layer = "overlay";
        group-by = "none";
        enable-markup = true;
        default-timeout = 5;
        ignore-transient = false;
      };

      # Urgency levels
      low = {
        timeout = 5;
        border-size = 1;
        padding = 8;
      };

      normal = {
        timeout = 10;
        border-size = 1;
        padding = 8;
      };

      critical = {
        timeout = 0; # 0 means no timeout
        border-size = 1;
        padding = 8;
      };
    };
  };
}
