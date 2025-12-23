{
  description = "the greatest nixos flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # add lanzaboote for secure boot later bro


    nix-flatpak.url = "github:gmodena/nix-flatpak/latest";
  };

  outputs = { self, nixpkgs, nix-flatpak, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        # lanzaboote eventually
        nix-flatpak.nixosModules.nix-flatpak
      ];
    };
  };
}
