{ config, lib, pkgs, ... }: {
  options.my.hm.audio = {
    enable = lib.mkEnableOption "инструменты для редактирования аудио";
  };

  config = lib.mkIf config.my.hm.audio.enable {
    home.packages = with pkgs; [
      ffmpeg
      id3v2
      exiftool
      python3Packages.mutagen
    ];
  };
}
