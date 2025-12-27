{ config, lib, ... }:

with lib;
let
  focused = config.lib.stylix.colors.withHashtag.base0D;
in {
  config = mkIf config.stylix.enable {
    xsession.windowManager.i3.config.colors.focused.indicator = mkForce focused;
  };
}
