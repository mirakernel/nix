{
  description = "Flake-конфигурация Mirakernel";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nur.url = "github:nix-community/NUR";
    sops-nix.url = "github:Mic92/sops-nix";
    playwright-web-flake.url = "github:pietdevries94/playwright-web-flake";
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    codex-cli-nix.url = "github:sadjow/codex-cli-nix";
    claude-code.url = "github:sadjow/claude-code-nix";
    thinkfan-ui.url = "github:mirakernel/thinkfan-ui?ref=flake-nix";
  };

  outputs = { nixpkgs, home-manager, sops-nix, plasma-manager, nixvim, nur, codex-cli-nix, claude-code, thinkfan-ui, playwright-web-flake, ... }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [ claude-code.overlays.default ];
    };
  in {
    nixosConfigurations.tsunami = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager
        ./hosts/tsunami/configuration.nix
      ];
      specialArgs = { inherit nixvim nur plasma-manager codex-cli-nix thinkfan-ui playwright-web-flake; };
    };

    homeConfigurations.kira = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit nur codex-cli-nix playwright-web-flake; };
      modules = [
        nixvim.homeModules.nixvim
        plasma-manager.homeModules.plasma-manager
        ./home/kira/home.nix
      ];
    };
  };
}
