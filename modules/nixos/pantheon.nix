{ config, lib, pkgs, ... }:
let
  cfg = config.my.pantheon;

  pkgAt = path: lib.attrByPath path null pkgs;
  firstExisting = candidates: lib.findFirst (path: pkgAt path != null) null candidates;
  packageFrom = candidates:
    let selected = firstExisting candidates;
    in lib.optional (selected != null) (pkgAt selected);

  elementaryApps = lib.concatLists [
    (packageFrom [ [ "pantheon" "files" ] [ "elementary-files" ] ])
    (packageFrom [ [ "pantheon" "terminal" ] [ "pantheon-terminal" ] ])
    (packageFrom [ [ "pantheon" "calculator" ] [ "pantheon-calculator" ] ])
    (packageFrom [ [ "pantheon" "calendar" ] [ "pantheon-calendar" ] ])
    (packageFrom [ [ "pantheon" "camera" ] [ "pantheon-camera" ] ])
    (packageFrom [ [ "pantheon" "music" ] [ "pantheon-music" ] ])
    (packageFrom [ [ "pantheon" "videos" ] [ "pantheon-videos" ] ])
    (packageFrom [ [ "pantheon" "photos" ] [ "pantheon-photos" ] ])
    (packageFrom [ [ "pantheon" "code" ] [ "pantheon-code" ] [ "elementary-code" ] ])
    (packageFrom [ [ "pantheon" "screenshot" ] [ "pantheon-screenshot" ] ])
  ];

  themePackages = lib.concatLists [
    (packageFrom [ [ "pantheon" "elementary-gtk-theme" ] [ "elementary-gtk-theme" ] ])
    (packageFrom [ [ "pantheon" "elementary-icon-theme" ] [ "elementary-icon-theme" ] ])
  ];
in {
  options.my.pantheon = {
    enable = lib.mkEnableOption "модуль Pantheon с приложениями elementary";

    gtkThemeName = lib.mkOption {
      type = lib.types.str;
      default = "io.elementary.stylesheet.blueberry";
      description = "Имя GTK-темы для сеанса Pantheon";
    };

    iconThemeName = lib.mkOption {
      type = lib.types.str;
      default = "elementary";
      description = "Имя темы иконок для сеанса Pantheon";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Дополнительные пакеты для Pantheon";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    services.xserver.displayManager.lightdm.enable = true;
    services.xserver.displayManager.defaultSession = "pantheon-wayland";
    services.xserver.desktopManager.pantheon.enable = true;

    environment.systemPackages = elementaryApps ++ themePackages ++ cfg.extraPackages;

    environment.sessionVariables = {
      GTK_THEME = cfg.gtkThemeName;
      ICON_THEME = cfg.iconThemeName;
      XCURSOR_THEME = cfg.iconThemeName;
    };
  };
}
