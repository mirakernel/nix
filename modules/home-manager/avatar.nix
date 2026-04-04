{ config, lib, ... }:
let
  cfg = config.my.hm.avatar;
  avatar = ../../imgs/tsunami-kira-avatar.jpg;
in
{
  options.my.hm.avatar = {
    enable = lib.mkEnableOption "аватар пользователя";
  };

  config = lib.mkIf cfg.enable {
    home.file.".face".source = avatar;
    home.file.".face.icon".source = avatar;
  };
}
