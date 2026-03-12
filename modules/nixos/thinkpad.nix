{ config, lib, pkgs, thinkfan-ui, ... }:
let
  cfg = config.my.nixos.thinkpad;
  system = pkgs.stdenv.hostPlatform.system;

  systemPackages =
    if builtins.hasAttr "packages" thinkfan-ui && builtins.hasAttr system thinkfan-ui.packages
    then thinkfan-ui.packages.${system}
    else { };

  thinkfanUiPackage =
    if builtins.hasAttr "default" systemPackages then
      systemPackages.default
    else if builtins.hasAttr "thinkfan-ui" systemPackages then
      systemPackages.thinkfan-ui
    else
      throw "thinkfan-ui flake does not expose packages.${system}.default or packages.${system}.thinkfan-ui";
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
