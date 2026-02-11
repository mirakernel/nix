{ config, lib, ... }:
let
  cfg = config.graphicalTablet;
in {
  options.graphicalTablet = {
    enable = lib.mkEnableOption "графический планшет (wacom + libinput)";

    user = lib.mkOption {
      type = lib.types.str;
      default = "kira";
      description = "Пользователь, которого добавить в группу input";
    };
  };

  config = lib.mkIf cfg.enable {
    services.libinput.enable = true;
    services.xserver.wacom.enable = true;
    users.users.${cfg.user}.extraGroups = [ "input" ];
  };
}
