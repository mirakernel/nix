{ config, lib, pkgs, ... }:
let
  cfg = config.my.plasma;
in {
  options.my.plasma = {
    enable = lib.mkEnableOption "модуль KDE Plasma";

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Дополнительные пакеты для KDE Plasma";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    services.displayManager.sddm.enable = true;
    services.displayManager.autoLogin.enable = true;
    services.displayManager.autoLogin.user = "kira";
    services.desktopManager.plasma6.enable = true;
    networking.networkmanager.enable = true;

    environment.systemPackages = with pkgs; [
      kdePackages.konsole
      kdePackages.kate
      kdePackages.kcalc
      kdePackages.spectacle
      kdePackages.plasma-nm
      kdePackages.bluedevil
    ] ++ cfg.extraPackages;
  };
}
