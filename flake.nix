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

    nvf.url = "github:notashelf/nvf";
    
    # debt
    debt.url = "github:jeebuscrossaint/debt";

    # my own project
    numlockwl.url = "github:jeebuscrossaint/numlockwl";

    # my other own project
    doomer.url = "github:jeebuscrossaint/doomer";

    # my own bar
    limebar.url = "github:jeebuscrossaint/limebar";

    # that other thing
    wart.url = "github:jeebuscrossaint/wart";
    
    # aocli
    aocli.url = "github:jeebuscrossaint/aocli";

    #prismlauncher
    prismlauncher.url = "github:PrismLauncher/PrismLauncher";

    # hyprpicker
    hyprpicker.url = "github:hyprwm/hyprpicker";

    # hyprpaper
    hyprpaper.url = "github:hyprwm/hyprpaper";

    # swayfx
    swayfx.url = "github:WillPower3309/swayfx";

    # xdg-desktop-portal-hyprland
    xdg-desktop-portal-hyprland.url = "github:hyprwm/xdg-desktop-portal-hyprland";

    #hypridle
    hypridle.url = "github:hyprwm/hypridle";

    # quickemu
    quickemu.url = "github:quickemu-project/quickemu";
    quickgui.url = "github:quickemu-project/quickgui";
    #nix-search
    nix-search.url = "github:peterldowns/nix-search-cli";

    #nix-index
    nix-index.url = "github:nix-community/nix-index";

    # swww
    swww.url = "github:LGFae/swww";

    # helix
    helix.url = "github:helix-editor/helix";

    # waybar
    waybar.url = "github:Alexays/Waybar";

    #rose-pine-hyprcursor
    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hyprlang.follows = "hyprland/hyprlang";
    };

    # yazi
    yazi.url = "github:sxyazi/yazi";

    # hyprpolkit agent
    hyprpolkitagent.url = "github:hyprwm/hyprpolkitagent";

    # conky
    conky.url = "github:brndnmtthws/conky";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs @ {
    nixpkgs,
    nix-ld,
    home-manager,
    stylix,
    ...
  }: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          stylix.nixosModules.stylix
          ./configuration.nix

          # This will enable nix-ld and add its modules
          nix-ld.nixosModules.nix-ld
          {programs.nix-ld.dev.enable = true;}
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
            ];
          }
        ];
      };
    };
  };
}
