
{
  description = "Home Manager configuration";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    stylix.url = "github:danth/stylix";
    
    nvf.url = "github:notashelf/nvf";
    
    doomer.url = "github:jeebuscrossaint/doomer";
    
    aocli.url = "github:jeebuscrossaint/aocli";
    
    nixcord.url = "github:kaylorben/nixcord";

    sxwm.url = "github:jeebuscrossaint/sxwm-flake";
    
    sf-mono-nerd-font.url = "github:jeebuscrossaint/sf-mono-nerd-font-flake";
    
    schizofox.url = "github:schizofox/schizofox";

    ww.url = "github:jeebuscrossaint/ww";

    woled.url = "github:jeebuscrossaint/woled";

    fresh.url = "github:sinelaw/fresh";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };
  
  outputs = { nixpkgs, home-manager, ... }@inputs: {
    homeConfigurations = {
      # Replace "amarnath" with your username
      amarnath = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        
        extraSpecialArgs = { inherit inputs; };
        
        modules = [
          ./home.nix
          inputs.stylix.homeModules.stylix
          inputs.nvf.homeManagerModules.default
          inputs.nixcord.homeModules.nixcord
          inputs.schizofox.homeManagerModules.default
          
        ];
      };
    };
  };
}
