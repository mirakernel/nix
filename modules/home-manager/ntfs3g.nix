{ config, lib, pkgs, ... }: {
  options.my.hm.ntfs3g = {
    enable = lib.mkEnableOption "утилиты для работы с NTFS через ntfs3g";
  };

  config = lib.mkIf config.my.hm.ntfs3g.enable {
    home.packages = with pkgs; [
      ntfs3g
    ];
  };
}
