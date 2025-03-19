{
  description = "younix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # browser please!
    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    # run random binaries please!
    nix-ld.url = "github:Mic92/nix-ld";

    # stylix (home manager gtk stylign is so incredibly butt)
    stylix.url = "github:danth/stylix";

	#vim joyer hyprland home manager tutorial
	hyprland.url = "github:hyprwm/Hyprland";
	
	#ewww input
	ewww.url = "github:elkowar/eww";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, nix-ld, home-manager, stylix, ... }: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
	  stylix.nixosModules.stylix
          ./configuration.nix
		  
          # This will enable nix-ld and add its modules
          nix-ld.nixosModules.nix-ld
          { programs.nix-ld.dev.enable = true; }

          # Home manager module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.amarnath = import ./home.nix;
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };
    };
  };
}
