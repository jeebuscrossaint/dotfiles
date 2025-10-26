
{ config, pkgs, ... }:

{
  programs.librewolf = {
    enable = true;

    # Optional privacy/performance settings
    settings = {
      "privacy.resistFingerprinting" = false;
      "webgl.disabled" = false;
      "privacy.trackingprotection.enabled" = true;
      "browser.startup.homepage" = "https://duckduckgo.com";
    };

    # Extensions you want installed in LibreWolf
    extensions = with pkgs.firefox-addons; [
      imagus
      ublock-origin
      better-canvas
      sponsorblock
      docsafterdark
      darkreader
      return-youtube-dislike
    ];

    # Optionally set a default theme
    theme = {
      name = "Dark";
      variant = "dark";
    };
  };
}
