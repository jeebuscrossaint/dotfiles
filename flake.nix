{
  description = "younix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # example using helix
    helix.url = "github:helix-editor/helix/master";

    # hyprlan
    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # rosepine hyprcursor
    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hyprlang.follows = "hyprland/hyprlang";
    };

    # browser please!
    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    # yazi
    yazi.url = "github:sxyazi/yazi";

    # run random binaries please!
    nix-ld.url = "github:Mic92/nix-ld";

    # swww wayland wallpaper woes!!
    swww.url = "github:LGFae/swww";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, nix-ld, home-manager, ... }: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
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
