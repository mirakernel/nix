{ pkgs, ... }: {
  imports = [ ../../modules/nixos/pantheon.nix ];

  system.stateVersion = "25.11";

  my.pantheon.enable = true;

  users.users.kira = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.kira = import ../../home/kira/home.nix;
}
