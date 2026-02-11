{ config, lib, ... }: {
  options.my.hm.plasma = {
    enable = lib.mkEnableOption "настройка KDE Plasma через plasma-manager";
  };

  config = lib.mkIf config.my.hm.plasma.enable {
    programs.plasma.enable = true;
  };
}
