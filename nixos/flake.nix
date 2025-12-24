{
  description = "the greatest nixos flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/latest";
  };

  outputs =
    {
      self,
      nixpkgs,
      lanzaboote,
      nix-flatpak,
      ...
    }:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix

          lanzaboote.nixosModules.lanzaboote

          (
            { pkgs, lib, ... }:
            {
              boot.loader.systemd-boot.enable = lib.mkForce false;

              boot.lanzaboote = {
                enable = true;
                pkiBundle = "/var/lib/sbctl";
              };
            }
          )

          nix-flatpak.nixosModules.nix-flatpak
        ];
      };
    };
}
