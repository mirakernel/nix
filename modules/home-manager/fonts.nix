{ config, lib, pkgs, ... }:
let
  cfg = config.my.hm.fonts;
in
{
  options.my.hm.fonts = {
    enable = lib.mkEnableOption "набор шрифтов";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.hack
      nerd-fonts.ubuntu
      nerd-fonts.ubuntu-mono
    ];
  };
}
