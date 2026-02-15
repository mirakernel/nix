{ config, lib, pkgs, ... }: {
  options.my.hm.sops = {
    enable = lib.mkEnableOption "утилиты sops/age";
  };

  config = lib.mkIf config.my.hm.sops.enable {
    home.packages = with pkgs; [
      sops
      age
    ];
  };
}
