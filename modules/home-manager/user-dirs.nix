{ config, pkgs, lib, ... }:
{
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "${config.home.homeDirectory}/desktop";
    download = "${config.home.homeDirectory}/downloads";
    documents = "${config.home.homeDirectory}/docs";
    music = "${config.home.homeDirectory}/music";
    pictures = "${config.home.homeDirectory}/imgs";
    videos = "${config.home.homeDirectory}/videos";
    templates = "${config.home.homeDirectory}/templates";
    publicShare = "${config.home.homeDirectory}/shared";
  };
}
