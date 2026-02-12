{ pkgs, ... }:
let
  wallpaper = ../../imgs/tsunami-kira-wallpaper-1.png;
in {
  imports = [
    ../../modules/home-manager/art.nix
    ../../modules/home-manager/apps.nix
    ../../modules/home-manager/ai.nix
    ../../modules/home-manager/floorp.nix
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/syncthing.nix
    ../../modules/home-manager/nixvim.nix
    ../../modules/home-manager/tmux.nix
    ../../modules/home-manager/term.nix
    ../../modules/home-manager/emacs.nix
    ../../modules/home-manager/vpn.nix
    ../../modules/home-manager/passwd.nix
    ../../modules/home-manager/user-dirs.nix
    ../../modules/home-manager/fonts.nix
    ../../modules/home-manager/plasma.nix
    ../../modules/home-manager/vscodium.nix
    ../../modules/home-manager/rust.nix
    ../../modules/home-manager/python.nix
  ];

  home.username = "kira";
  home.homeDirectory = "/home/kira";
  home.stateVersion = "25.11";

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      extra-substituters = [
        "https://mirror.yandex.ru/nixos/"
        "https://cache.nixos.org/"
      ];
    };
  };

  programs.home-manager.enable = true;
  my.hm.plasma.enable = true;
  my.hm.vscodium.enable = true;
  my.hm.emacs.enable = true;
  my.hm.rust.enable = true;
  my.hm.python.enable = true;

  dconf.enable = true;
  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-uri = "file://${wallpaper}";
      picture-uri-dark = "file://${wallpaper}";
      picture-options = "zoom";
    };
  };

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
}
