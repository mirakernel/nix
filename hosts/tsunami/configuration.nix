{ config, pkgs, nixvim, nur, plasma-manager, codex-cli-nix, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/plasma.nix
    ../../modules/nixos/virt.nix
    ../../modules/nixos/container.nix
    ../../modules/nixos/graphical-tablet.nix
    ../../modules/nixos/netbird.nix
    ../../modules/nixos/thinkpad.nix
  ];

  system.stateVersion = "25.11";
  nixpkgs.config.allowUnfree = true;
  networking.hostName = "tsunami";
  time.timeZone = "Asia/Yekaterinburg";
  i18n.defaultLocale = "ru_RU.UTF-8";
  i18n.supportedLocales = [ "ru_RU.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];

  console = {
    useXkbConfig = true;
    font = "cyr-sun16";
  };

  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:alt_shift_toggle";
  };

  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      efiSupport = true;
      devices = [ "nodev" ];
    };
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [
      "https://mirror.yandex.ru/nixos/"
      "https://cache.nixos.org/"
    ];
  };

  sops = {
    age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };

    secrets = {
      "netbird/mirakernel_setup_key" = {
        sopsFile = ../../secrets/netbird.yaml;
      };
      "netbird/techmind_setup_key" = {
        sopsFile = ../../secrets/netbird.yaml;
      };
    };
  };

  services.fprintd.enable = true;
  services.accounts-daemon.enable = true;
  security.pam.services = {
    login.fprintAuth = true;
    sudo.fprintAuth = true;
    sddm.fprintAuth = true;
  };

  my.plasma.enable = true;
  my.nixos.thinkpad.enable = true;
  my.nixos.netbird = {
    enable = true;
    ui.enable = true;
    profiles = {
      mirakernel = {
        managementUrl = "https://netbird.mirakernel.ru";
        setupKeyFile = config.sops.secrets."netbird/mirakernel_setup_key".path;
        port = 51820;
        interface = "nb-mira";
        dnsResolverAddress = "127.20.0.1";
      };

      techmind = {
        managementUrl = "https://netbird.techmindsolutions.ru";
        setupKeyFile = config.sops.secrets."netbird/techmind_setup_key".path;
        port = 51821;
        interface = "nb-tech";
        dnsResolverAddress = "127.20.0.2";
      };
    };
  };

  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = true;
    settings = {
      bind-interfaces = true;
      listen-address = [ "127.0.0.1" "::1" ];
      no-resolv = true;
      server = [
        "/netbird.selfhosted/127.20.0.1#53"
        "/tms.ru/127.20.0.2#53"
        "1.1.1.1"
        "9.9.9.9"
      ];
    };
  };

  services.resolved.enable = false;
  networking.resolvconf.useLocalResolver = true;
  networking.networkmanager.dns = "none";
  networking.nameservers = [ "127.0.0.1" ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  graphicalTablet.enable = true;
  virt.kvm.enable = true;
  virt.vbox.enable = true;
  container.docker.enable = true;
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "NixOS SMB Server";
        "security" = "user";
        "map to guest" = "Bad User";
        "guest account" = "kira";
      };

      shared = {
        "path" = "/home/kira/shared";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "force user" = "kira";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  users.users.kira = {
    isNormalUser = true;
    description = "Миракернел";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  systemd.tmpfiles.rules = let
    username = "kira";
    iconPath = ../../imgs/tsunami-kira-avatar.jpg;
  in [
    "d /var/lib/AccountsService/icons 0755 root root -"
    "d /var/lib/AccountsService/users 0755 root root -"
    "L+ /var/lib/AccountsService/icons/${username} - - - - ${iconPath}"
    "f+ /var/lib/AccountsService/users/${username} 0600 root root - [User]\\nIcon=/var/lib/AccountsService/icons/${username}\\nSystemAccount=false\\n"
    "d /home/kira/shared 0775 kira users -"
  ];

  programs.zsh.enable = true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "bak";
  home-manager.sharedModules = [
    nixvim.homeModules.nixvim
    plasma-manager.homeModules.plasma-manager
  ];
  home-manager.extraSpecialArgs = { inherit nur codex-cli-nix; };
  home-manager.users.kira = import ../../home/kira/home.nix;
}
