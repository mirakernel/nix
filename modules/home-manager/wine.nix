{ config, lib, pkgs, ... }: {
  options.my.hm.wine = {
    enable = lib.mkEnableOption "wine";
  };

  config = lib.mkIf config.my.hm.wine.enable {
    home.packages = [
      pkgs.wineWow64Packages.stable
      pkgs.winetricks
    ];
  };
}
