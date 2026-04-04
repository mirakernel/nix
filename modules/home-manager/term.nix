{ config, lib, ... }:
let
  cfg = config.my.hm.term;
in {
  options.my.hm.term = {
    enable = lib.mkEnableOption "настройка терминала";
  };

  config = lib.mkIf cfg.enable { };
}
