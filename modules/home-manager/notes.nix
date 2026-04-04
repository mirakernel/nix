{ config, lib, pkgs, ... }:
let
  cfg = config.my.hm.notes;
in
{
  options.my.hm.notes = {
    enable = lib.mkEnableOption "приложения для заметок";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      obsidian
    ];
  };
}
