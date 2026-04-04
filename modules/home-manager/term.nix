{ config, lib, pkgs, ... }:
let
  cfg = config.my.hm.term;
in
{
  options.my.hm.term = {
    enable = lib.mkEnableOption "настройка терминала";
  };

  config = lib.mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      settings = {
        terminal.shell = {
          program = "${pkgs.tmux}/bin/tmux";
          args = [ "new-session" "-A" "-s" "main" ];
        };
        font = {
          normal = {
            family = "JetBrainsMono Nerd Font";
          };
        };
        window = {
          opacity = 0.96;
        };
      };
    };
  };
}
