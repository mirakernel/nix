{ config, lib, pkgs, ... }: {
  options.my.hm.torrent = {
    enable = lib.mkEnableOption "настройка qBittorrent";
  };

  config = lib.mkIf config.my.hm.torrent.enable {
    home.packages = with pkgs; [ qbittorrent ];
  };
}
