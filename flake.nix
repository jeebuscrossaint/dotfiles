{
  description = "younix";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05"; # nixos-unstable -> nixos-25.05
    # browser please!
    #zen-browser.url = "github:0xc000022070/zen-browser-flake";
    # run random binaries please!
    #nix-ld.url = "github:Mic92/nix-ld";
    # stylix (home manager gtk stylign is so incredibly butt)
    stylix.url = "github:danth/stylix/release-25.05"; # use stable
    #vim joyer hyprland home manager tutorial
    #hyprland.url = "github:hyprwm/Hyprland";

    #ewww input
    # ewww.url = "github:elkowar/eww";

    nvf.url = "github:notashelf/nvf";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # debt
    # debt.url = "github:jeebuscrossaint/debt";

    # my own project
    #numlockwl.url = "github:jeebuscrossaint/numlockwl";

    # my other own project
    doomer.url = "github:jeebuscrossaint/doomer";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    # my own bar
    # limebar.url = "github:jeebuscrossaint/limebar";

    # that other thing
    # wart.url = "github:jeebuscrossaint/wart";

    # aocli
    aocli.url = "github:jeebuscrossaint/aocli";

    #nix-index
    nix-index.url = "github:nix-community/nix-index";
    schizofox.url = "github:schizofox/schizofox";
    nix-flatpak.url = "github:gmodena/nix-flatpak/latest";

    # nixcord
    nixcord = {
      url = "github:kaylorben/nixcord";
    };

    sf-mono-nerd-font = {
      url = "github:jeebuscrossaint/sf-mono-nerd-font-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # hyprpolkit agent
    # hyprpolkitagent.url = "github:hyprwm/hyprpolkitagent";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ {
    nixpkgs,
    #nix-ld,
    home-manager,
    stylix,
    ...
  }: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          inputs.stylix.nixosModules.stylix
          #          inputs.fht-compositor.nixosModules.default
          inputs.nix-flatpak.nixosModules.nix-flatpak
          ./configuration.nix

          # This will enable nix-ld and add its modules
          #nix-ld.nixosModules.nix-ld
          #{programs.nix-ld.dev.enable = true;}
          # Home manager module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.amarnath = import ./home.nix;
            home-manager.extraSpecialArgs = {inherit inputs;};
            # Add nvf module to home-manager
            home-manager.sharedModules = [
              inputs.nvf.homeManagerModules.default
              inputs.nixcord.homeModules.nixcord
              inputs.schizofox.homeManagerModules.default
            ];
          }
        ];
      };
    };
  };
}
