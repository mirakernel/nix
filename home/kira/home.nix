{ pkgs, lib, ... }: {
  home.username = "kira";
  home.homeDirectory = "/home/kira";
  home.stateVersion = "25.11";

  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      extra-substituters = [
        "https://mirror.yandex.ru/nixos/"
        "https://cache.nixos.org/"
      ];
      extra-trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypb7GmY0+E5d8Xl8v8M8x0Gv6U="
      ];
    };
  };

  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
    shellAliases = {
      cdx = "codex";
    };
  };

  home.packages = lib.optionals (pkgs ? codex) [ pkgs.codex ];
}
