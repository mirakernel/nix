{ config, lib, pkgs, ... }: {
  options.my.hm.android = {
    enable = lib.mkEnableOption "инструменты Android (adb, fastboot)";
  };

  config = lib.mkIf config.my.hm.android.enable {
    home.packages = with pkgs; [
      android-tools
    ];
  };
}
