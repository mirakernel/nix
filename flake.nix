{
  description = "Flake-конфигурация Mirakernel";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nur.url = "github:nix-community/NUR";
    sops-nix.url = "github:Mic92/sops-nix";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, sops-nix, nixvim, ... }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };
  in {
    nixosConfigurations.tsunami = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager
        ./hosts/tsunami/configuration.nix
      ];
      specialArgs = { inherit nixvim; };
    };

    homeConfigurations.kira = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        nixvim.homeManagerModules.nixvim
        ./home/kira/home.nix
      ];
    };
  };
}
