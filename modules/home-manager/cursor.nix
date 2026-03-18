{ config, lib, pkgs, ... }:
let
  cfg = config.my.hm.cursor;
in
{
  options.my.hm.cursor = {
    enable = lib.mkEnableOption "установка Cursor";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      code-cursor-fhs
      cursor-cli
    ];
  };
}
