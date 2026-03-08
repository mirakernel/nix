{ config, lib, pkgs, ... }: {
  options.my.hm.chromium = {
    enable = lib.mkEnableOption "chromium";
  };

  config = lib.mkIf config.my.hm.chromium.enable {
    home.packages = [
      pkgs.chromium
    ];
  };
}
