{ config, lib, pkgs, ... }: {
  options.my.hm.gns3 = {
    enable = lib.mkEnableOption "GNS3 GUI и локальный server";
  };

  config = lib.mkIf config.my.hm.gns3.enable {
    home.packages = with pkgs; [
      gns3-gui
      gns3-server
      dynamips
      ubridge
    ];
  };
}
