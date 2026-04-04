{ config, lib, ... }:
let
  cfg = config.my.hm.syncthing;
in
{
  options.my.hm.syncthing = {
    enable = lib.mkEnableOption "настройка Syncthing";
  };

  config = lib.mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      tray.enable = false;
    };
  };
}
