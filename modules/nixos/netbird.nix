{ config, lib, ... }:
let
  cfg = config.my.nixos.netbird;
in {
  options.my.nixos.netbird = {
    enable = lib.mkEnableOption "клиент NetBird";

    ui.enable = lib.mkEnableOption "NetBird UI";

    profiles = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({ name, ... }: {
        options = {
          managementUrl = lib.mkOption {
            type = lib.types.str;
            description = "URL management-сервера NetBird для профиля";
          };

          setupKeyFile = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Путь к файлу setup key (например /run/secrets/...)";
          };

          port = lib.mkOption {
            type = lib.types.port;
            default = 51820;
            description = "UDP-порт NetBird-клиента";
          };

          interface = lib.mkOption {
            type = lib.types.str;
            default = "nb-${name}";
            description = "Имя сетевого интерфейса NetBird";
          };

          hardened = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Запускать клиент в hardened-режиме";
          };

          dnsResolverAddress = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Локальный адрес DNS-резолвера профиля NetBird";
          };

          dnsResolverPort = lib.mkOption {
            type = lib.types.port;
            default = 53;
            description = "Порт DNS-резолвера профиля NetBird";
          };
        };
      }));
      default = { };
      description = "Декларативные профили NetBird, маппятся в services.netbird.clients";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      services.netbird.ui.enable = cfg.ui.enable;
    }

    (lib.mkIf (cfg.profiles == { }) {
      services.netbird.enable = true;
    })

    (lib.mkIf (cfg.profiles != { }) {
      services.netbird.clients = lib.mapAttrs
        (_: profile:
          {
            inherit (profile) port interface hardened;
          } // lib.optionalAttrs (profile.dnsResolverAddress != null) {
            "dns-resolver".address = profile.dnsResolverAddress;
            "dns-resolver".port = profile.dnsResolverPort;
          } // lib.optionalAttrs (profile.setupKeyFile != null) {
            login.enable = true;
            login.setupKeyFile = profile.setupKeyFile;
            login.systemdDependencies = [ "network-online.target" ];
          })
        cfg.profiles;

      systemd.services = lib.mapAttrs'
        (name: profile:
          lib.nameValuePair "netbird-${name}-login" (lib.mkIf (profile.setupKeyFile != null) {
            script = lib.mkForce ''
              set -euo pipefail
              export HOME="/tmp/netbird-login-${name}"
              export XDG_CONFIG_HOME="$HOME/.config"
              mkdir -p "$XDG_CONFIG_HOME"

              "${lib.getExe config.services.netbird.package}" up \
                --daemon-addr=${lib.escapeShellArg config.services.netbird.clients.${name}.environment.NB_DAEMON_ADDR} \
                --service=${lib.escapeShellArg config.services.netbird.clients.${name}.environment.NB_SERVICE} \
                --management-url=${lib.escapeShellArg profile.managementUrl} \
                --setup-key-file="$NB_SETUP_KEY_FILE"
            '';
          }))
        cfg.profiles;
    })
  ]);
}
