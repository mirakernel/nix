{ config, lib, ... }:
let
  cfg = config.my.nixos.appimage;
in {
  options.my.nixos.appimage = {
    enable = lib.mkEnableOption "поддержка AppImage";
  };

  config = lib.mkIf cfg.enable {
    programs.appimage.enable = true;
    programs.appimage.binfmt = true;
  };
}
