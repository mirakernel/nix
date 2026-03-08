{ config, lib, pkgs, ... }:
let
  cfg = config.virt;
in {
  options.virt = {
    user = lib.mkOption {
      type = lib.types.str;
      default = "kira";
      description = "Пользователь, которого добавить в группы виртуализации";
    };

    kvm.enable = lib.mkEnableOption "QEMU/KVM + libvirt + virt-manager";
    vbox.enable = lib.mkEnableOption "VirtualBox host";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.kvm.enable {
      virtualisation.libvirtd.enable = true;
      programs.virt-manager.enable = true;
      virtualisation.spiceUSBRedirection.enable = true;
      users.users.${cfg.user}.extraGroups = [ "libvirtd" "kvm" ];

      systemd.services.virt-secret-init-encryption.serviceConfig.ExecStart = lib.mkForce
        "${pkgs.runtimeShell} -c 'umask 0077 && (${pkgs.coreutils}/bin/dd if=/dev/random status=none bs=32 count=1 | ${lib.getExe' pkgs.systemd "systemd-creds"} encrypt --name=secrets-encryption-key - /var/lib/libvirt/secrets/secrets-encryption-key)'";
    })

    (lib.mkIf cfg.vbox.enable {
      virtualisation.virtualbox.host.enable = true;
      virtualisation.virtualbox.host.enableKvm = false;
      virtualisation.virtualbox.host.addNetworkInterface = false;
      users.users.${cfg.user}.extraGroups = [ "vboxusers" ];
    })
  ];
}
