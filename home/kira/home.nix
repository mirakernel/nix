{ pkgs, lib, ... }: {
  imports = [
    ../../modules/home-manager/art.nix
    ../../modules/home-manager/floorp.nix
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/syncthing.nix
    ../../modules/home-manager/nixvim.nix
    ../../modules/home-manager/tmux.nix
    ../../modules/home-manager/passwd.nix
    ../../modules/home-manager/user-dirs.nix
    ../../modules/home-manager/fonts.nix
  ];

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
      codex = "ALL_PROXY='socks5h://localhost:2080' HTTPS_PROXY='socks5h://localhost:2080' HTTP_PROXY='http://localhost:2080' codex";
      proxy = "export ALL_PROXY='socks5h://localhost:2080' all_proxy='socks5h://localhost:2080' HTTPS_PROXY='socks5h://localhost:2080' https_proxy='socks5h://localhost:2080' HTTP_PROXY='http://localhost:2080' http_proxy='http://localhost:2080'";
    };
  };

  home.packages = lib.optionals (pkgs ? codex) [ pkgs.codex ];
}
