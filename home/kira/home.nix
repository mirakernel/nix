{ lib, pkgs, ... }:
let
  wallpaper = ../../imgs/kira-wallpaper.png;
in {
  imports = [
    ../../modules/home-manager/art.nix
    ../../modules/home-manager/avatar.nix
    ../../modules/home-manager/social.nix
    ../../modules/home-manager/notes.nix
    ../../modules/home-manager/gns3.nix
    ../../modules/home-manager/ai.nix
    ../../modules/home-manager/floorp.nix
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/syncthing.nix
    ../../modules/home-manager/nixvim.nix
    ../../modules/home-manager/tmux.nix
    ../../modules/home-manager/term.nix
    ../../modules/home-manager/shell.nix
    ../../modules/home-manager/ssh.nix
    ../../modules/home-manager/sops.nix
    ../../modules/home-manager/emacs.nix
    ../../modules/home-manager/passwd.nix
    ../../modules/home-manager/user-dirs.nix
    ../../modules/home-manager/fonts.nix
    ../../modules/home-manager/office.nix
    ../../modules/home-manager/db.nix
    ../../modules/home-manager/archive.nix
    ../../modules/home-manager/ntfs3g.nix
    ../../modules/home-manager/plasma.nix
    ../../modules/home-manager/vscodium.nix
    ../../modules/home-manager/rust.nix
    ../../modules/home-manager/js.nix
    ../../modules/home-manager/python.nix
    ../../modules/home-manager/audio.nix
    ../../modules/home-manager/android.nix
    ../../modules/home-manager/godot.nix
    ../../modules/home-manager/chromium.nix
    ../../modules/home-manager/cursor.nix
    ../../modules/home-manager/steam.nix
    ../../modules/home-manager/wine.nix
    ../../modules/home-manager/torrent.nix
    ../../modules/home-manager/tor.nix
    ../../modules/home-manager/i2p.nix
  ];

  home.username = "kira";
  home.homeDirectory = "/home/kira";
  home.stateVersion = "25.11";

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      extra-substituters = [
        "https://cache.nixos.org/"
        "https://mirror.yandex.ru/nixos/"
        "https://nix-mirror.freetls.fastly.net"
      ];
    };
  };

  programs.home-manager.enable = true;
  my.hm.art.enable = true;
  my.hm.avatar.enable = true;
  my.hm.notes.enable = true;
  my.hm.floorp.enable = true;
  my.hm.git.enable = true;
  my.hm.syncthing.enable = true;
  my.hm.nixvim.enable = true;
  my.hm.tmux.enable = true;
  my.hm.term.enable = true;
  my.hm.passwd.enable = true;
  my.hm.user-dirs.enable = true;
  my.hm.fonts.enable = true;
  my.hm.shell.enable = true;
  my.hm.ssh.enable = true;
  my.hm.gns3.enable = true;
  my.hm.plasma.enable = true;
  my.hm.office.enable = true;
  my.hm.db.enable = true;
  my.hm.archive.enable = true;
  my.hm.ntfs3g.enable = true;
  my.hm.rust.enable = true;
  my.hm.js.enable = true;
  my.hm.python.enable = true;
  my.hm.audio.enable = true;
  my.hm.android.enable = true;
  my.hm.godot.enable = true;
  my.hm.chromium.enable = true;
  my.hm.steam.enable = true;
  my.hm.wine.enable = true;
  my.hm.torrent.enable = true;
  my.hm.tor.enable = true;
  my.hm.i2p.enable = true;

  my.hm.vscodium.enable = false;
  my.hm.emacs.enable = false;
  my.hm.cursor.enable = false;
  my.hm.sops.enable = false;
  my.hm.ai.enable = false;
  my.hm.social.enable = false;

  dconf.enable = true;
  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-uri = "file://${wallpaper}";
      picture-uri-dark = "file://${wallpaper}";
      picture-options = "zoom";
    };
  };

}
