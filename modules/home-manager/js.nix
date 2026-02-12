{ config, lib, pkgs, ... }: {
  options.my.hm.js = {
    enable = lib.mkEnableOption "настройка JS/Node для пользователя";
  };

  config = lib.mkIf config.my.hm.js.enable {
    home.packages = with pkgs; [
      nodejs
      bun
      pnpm
      yarn
    ];
  };
}
