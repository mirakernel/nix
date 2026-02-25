{ config, lib, pkgs, ... }: {
  options.my.hm.archive = {
    enable = lib.mkEnableOption "поддержка архивов, включая RAR, на уровне Home Manager";
  };

  config = lib.mkIf config.my.hm.archive.enable {
    home.packages = [
      pkgs.kdePackages.ark
      pkgs.unrar
      pkgs.unar
      pkgs.unzip
      pkgs.zip
      pkgs.p7zip
    ];
  };
}
