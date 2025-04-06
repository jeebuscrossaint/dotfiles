{ config, lib, ... }:

with lib;
let
  focused = config.lib.stylix.colors.withHashtag.base0D;
in {
  config = mkIf config.stylix.enable {
    wayland.windowManager.sway.config.colors.focused.indicator = mkForce focused;
  };
}
