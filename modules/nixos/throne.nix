{ config, lib, ... }:
let
  cfg = config.my.nixos.throne;
in {
  options.my.nixos.throne = {
    enable = lib.mkEnableOption "настройка Throne";
  };

  config = lib.mkIf cfg.enable {
    programs.throne = {
      enable = true;
      tunMode.enable = true;
    };
  };
}
