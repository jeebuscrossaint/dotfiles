{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.spicetify-nix.homeManagerModules.spicetify
  ];

  programs.spicetify = {
    enable = true;
  };
}
