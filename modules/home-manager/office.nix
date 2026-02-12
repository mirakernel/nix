{ config, lib, pkgs, ... }: {
  options.my.hm.office = {
    enable = lib.mkEnableOption "установка LibreOffice с русской локализацией";
  };

  config = lib.mkIf config.my.hm.office.enable {
    home.packages = [
      pkgs."libreoffice-qt-fresh"
      pkgs.hunspellDicts.ru_RU
      pkgs.hyphenDicts.ru_RU
    ];

    home.sessionVariables = {
      SAL_USE_VCLPLUGIN = "kf6";
    };
  };
}
