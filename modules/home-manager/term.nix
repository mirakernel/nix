{ config, lib, pkgs, ... }:
let
  cfg = config.my.hm.term;
in
{
  options.my.hm.term = {
    enable = lib.mkEnableOption "настройка терминала";
  };

  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      font = {
        name = "JetBrainsMono Nerd Font";
      };
      settings = {
        linux_display_server = "x11";
        shell = "${pkgs.tmux}/bin/tmux new-session -A -s main";
        background_opacity = "0.96";
      };
    };
  };
}
