{ config, lib, pkgs, ... }: {
  options.my.hm.godot = {
    enable = lib.mkEnableOption "Godot";
  };

  config = lib.mkIf config.my.hm.godot.enable {
    home.packages = [ pkgs.godot ];
  };
}
