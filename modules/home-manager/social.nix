{ config, lib, pkgs, ... }:
let
  cfg = config.my.hm.social;
in
{
  options.my.hm.social = {
    enable = lib.mkEnableOption "социальные приложения";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ ];
  };
}
