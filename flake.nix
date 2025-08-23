{
  description = "younix";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05"; # nixos-unstable -> nixos-25.05
    # browser please!
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    # run random binaries please!
    #nix-ld.url = "github:Mic92/nix-ld";
    # stylix (home manager gtk stylign is so incredibly butt)
    stylix.url = "github:danth/stylix/release-25.05"; # use stable
    #vim joyer hyprland home manager tutorial
    #hyprland.url = "github:hyprwm/Hyprland";

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

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
    numlockwl.url = "github:jeebuscrossaint/numlockwl";

    # my other own project
    doomer.url = "github:jeebuscrossaint/doomer";

    # my own bar
    # limebar.url = "github:jeebuscrossaint/limebar";

    # that other thing
    # wart.url = "github:jeebuscrossaint/wart";

    # aocli
    aocli.url = "github:jeebuscrossaint/aocli";

    #prismlauncher
    # prismlauncher.url = "github:PrismLauncher/PrismLauncher";

    # hyprpicker
    # hyprpicker.url = "github:hyprwm/hyprpicker";

    # hyprpaper
    # hyprpaper.url = "github:hyprwm/hyprpaper";

    # swayfx
    # swayfx.url = "github:WillPower3309/swayfx";

    # xdg-desktop-portal-hyprland
    # xdg-desktop-portal-hyprland.url = "github:hyprwm/xdg-desktop-portal-hyprland";

    #hypridle
    # hypridle.url = "github:hyprwm/hypridle";

    # quickemu
    # quickemu.url = "github:quickemu-project/quickemu";
    # quickgui.url = "github:quickemu-project/quickgui";
    #nix-search
    #nix-search.url = "github:peterldowns/nix-search-cli";

    #nix-index
    nix-index.url = "github:nix-community/nix-index";
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    schizofox.url = "github:schizofox/schizofox";
    nix-flatpak.url = "github:gmodena/nix-flatpak/latest";

    # swww
    # swww.url = "github:LGFae/swww";

    # helix
    # helix.url = "github:helix-editor/helix";

    # waybar
    # waybar.url = "github:Alexays/Waybar";

    # nixcord
    nixcord = {
      url = "github:kaylorben/nixcord";
    };

    sf-mono-nerd-font = {
      url = "github:jeebuscrossaint/sf-mono-nerd-font-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # fht-compositor
    fht-compositor = {
      url = "github:nferhat/fht-compositor";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "";
    };
    #rose-pine-hyprcursor
    #rose-pine-hyprcursor = {
    #  url = "github:ndom91/rose-pine-hyprcursor";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #  inputs.hyprlang.follows = "hyprland/hyprlang";
    #};

    # yazi
    #yazi.url = "github:sxyazi/yazi";

    # hyprpolkit agent
    # hyprpolkitagent.url = "github:hyprwm/hyprpolkitagent";

    # ironbar
    #ironbar = {
    #	url = "github:JakeStanger/ironbar";
    #	inputs.nixpkgs.follows = "nixpkgs";
    #};

    # conky
    #conky.url = "github:brndnmtthws/conky";

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
          inputs.fht-compositor.nixosModules.default
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
              inputs.plasma-manager.homeManagerModules.plasma-manager
            ];
          }
        ];
      };
    };
  };
}
