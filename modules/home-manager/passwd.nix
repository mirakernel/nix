{ config, lib, pkgs, ... }:
let
  cfg = config.my.hm.passwd;
in
{
  options.my.hm.passwd = {
    enable = lib.mkEnableOption "менеджер паролей";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      keepassxc
    ];
  };
}
