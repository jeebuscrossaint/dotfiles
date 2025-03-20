{ config, lib, pkgs, ... }:

{
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock;
    settings = {
      clock = true;
      timestr = "%-I:%M %p";
      datestr = "%a, %B %e";
      "submit-on-touch" = true;
      screenshots = true;
      "fade-in" = 0.2;
      grace = 5;
      "effect-blur" = "20x2";
      # effect-greyscale = true;  # Commented out in your config
      indicator = true;
      "indicator-radius" = 80;
      "indicator-thickness" = 5;
      "indicator-caps-lock" = true;
      "disable-caps-lock-text" = true;
    };
  };
}
