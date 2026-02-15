{ config, lib, pkgs, thinkfan-ui, ... }:
let
  cfg = config.my.nixos.thinkpad;

  systemPackages =
    if builtins.hasAttr "packages" thinkfan-ui && builtins.hasAttr pkgs.system thinkfan-ui.packages
    then thinkfan-ui.packages.${pkgs.system}
    else { };

  thinkfanUiPackage =
    if builtins.hasAttr "default" systemPackages then
      systemPackages.default
    else if builtins.hasAttr "thinkfan-ui" systemPackages then
      systemPackages.thinkfan-ui
    else
      throw "thinkfan-ui flake does not expose packages.${pkgs.system}.default or packages.${pkgs.system}.thinkfan-ui";
in {
  options.my.nixos.thinkpad = {
    enable = lib.mkEnableOption "ThinkPad-specific packages";
  };

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [ "thinkpad_acpi" ];
    boot.extraModprobeConfig = ''
      options thinkpad_acpi fan_control=1
    '';

    environment.systemPackages = [ thinkfanUiPackage ];
  };
}
