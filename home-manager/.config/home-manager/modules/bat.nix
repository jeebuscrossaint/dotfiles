{ config, lib, pkgs, ... }:

{
programs.bat = {
  enable = true;
  # # package = pkgs.emptyDirectory;
  config = {
    #theme = "TwoDark";
    pager = "less -FR";
    map-syntax = [ "*.jenkinsfile:Groovy" "*.props:Java Properties" ];
  };
  extraPackages = with pkgs.bat-extras; [ batdiff batman batgrep ];
};
}
