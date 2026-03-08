{ config, lib, pkgs, ... }:
let
  cfg = config.my.nixos.waydroid;
in {
  options.my.nixos.waydroid = {
    enable = lib.mkEnableOption "контейнер Android через Waydroid";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.waydroid.enable = true;
    virtualisation.waydroid.package = pkgs.waydroid-nftables;
  };
}
