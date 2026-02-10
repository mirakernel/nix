{ pkgs, ... }: {
  imports = [ ../../modules/nixos/pantheon.nix ];

  system.stateVersion = "25.11";
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [
      "https://mirror.yandex.ru/nixos/"
      "https://cache.nixos.org/"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypb7GmY0+E5d8Xl8v8M8x0Gv6U="
    ];
  };

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
