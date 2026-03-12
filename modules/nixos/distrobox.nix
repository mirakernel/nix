{ config, lib, pkgs, ... }:
let
  cfg = config.my.nixos.distrobox;
in {
  options.my.nixos.distrobox = {
    enable = lib.mkEnableOption "инструмент для контейнеров distrobox";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      distrobox
      kontainer
    ];
  };
}
