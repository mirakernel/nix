{ config, lib, pkgs, ... }: {
  options.my.hm.steam = {
    enable = lib.mkEnableOption "steam";
  };

  config = lib.mkIf config.my.hm.steam.enable {
    home.packages = [ pkgs.steam ];
  };
}
