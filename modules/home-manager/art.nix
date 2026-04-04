{ config, lib, pkgs, ... }:
let
  cfg = config.my.hm.art;
in
{
  options.my.hm.art = {
    enable = lib.mkEnableOption "набор графических приложений";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      krita
      gimp
      inkscape
      blockbench
      sweethome3d.application
    ];
  };
}
