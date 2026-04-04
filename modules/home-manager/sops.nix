{ config, lib, pkgs, osConfig ? null, ... }:
let
  defaultKeyFile =
    if osConfig != null
    then "/var/lib/sops-nix/key.txt"
    else "${config.xdg.configHome}/sops/age/keys.txt";
  hasManagedSecrets =
    (config.sops.secrets != { }) || (config.sops.templates != { });
in {
  options.my.hm.sops = {
    enable = lib.mkEnableOption "утилиты sops/age";
  };

  config = lib.mkIf config.my.hm.sops.enable {
    sops.age.keyFile = defaultKeyFile;

    home.packages = with pkgs; [
      sops
      age
    ];

    # Upstream sops-nix may try to restart the user unit before Home Manager
    # reloads the user systemd daemon, which fails on standalone HM setups.
    home.activation.sops-nix = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && hasManagedSecrets) (
      lib.mkForce (lib.hm.dag.entryAfter [ "reloadSystemd" ] ''
        systemdStatus=$(env XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}" \
          PATH="${lib.dirOf config.systemd.user.systemctlPath}:$PATH" \
          ${config.systemd.user.systemctlPath} --user is-system-running 2>&1 || true)

        if [[ $systemdStatus == 'running' || $systemdStatus == 'degraded' ]]; then
          env XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}" \
            PATH="${lib.dirOf config.systemd.user.systemctlPath}:$PATH" \
            ${config.systemd.user.systemctlPath} restart --user sops-nix
        else
          echo "User systemd daemon not running. Probably executed on boot where no manual start/reload is needed."
        fi

        unset systemdStatus
      '')
    );
  };
}
