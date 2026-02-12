{ config, lib, pkgs, ... }: {
  options.my.hm.office = {
    enable = lib.mkEnableOption "установка LibreOffice с русской локализацией";
  };

  config = lib.mkIf config.my.hm.office.enable {
    home.packages = with pkgs; [
      libreoffice
      hunspellDicts.ru_RU
      hyphenDicts.ru_RU
    ];

    home.sessionVariables = {
      # Force KDE/Qt UI backend so LibreOffice follows Plasma theme.
      SAL_USE_VCLPLUGIN = "kf6";
    };
  };
}
