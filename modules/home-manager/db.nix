{ config, lib, pkgs, ... }: {
  options.my.hm.db = {
    enable = lib.mkEnableOption "установка DBeaver для пользователя";
  };

  config = lib.mkIf config.my.hm.db.enable {
    home.packages = [
      pkgs.dbeaver-bin
    ];
  };
}
