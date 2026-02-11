{ config, lib, ... }:
let
  cfg = config.container;
in {
  options.container = {
    user = lib.mkOption {
      type = lib.types.str;
      default = "kira";
      description = "Пользователь, которого добавить в группы контейнеризации";
    };

    docker.enable = lib.mkEnableOption "Docker";
    podman.enable = lib.mkEnableOption "Podman";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.docker.enable {
      virtualisation.docker.enable = true;
      users.users.${cfg.user}.extraGroups = [ "docker" ];
    })

    (lib.mkIf cfg.podman.enable {
      virtualisation.podman.enable = true;
      users.users.${cfg.user}.extraGroups = [ "podman" ];
    })
  ];
}
