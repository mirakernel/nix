{ pkgs, nixvim, nur, plasma-manager, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/plasma.nix
    ../../modules/nixos/virt.nix
    ../../modules/nixos/container.nix
    ../../modules/nixos/graphical-tablet.nix
  ];

  system.stateVersion = "25.11";
  nixpkgs.config.allowUnfree = true;
  time.timeZone = "Europe/Moscow";
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

  services.fprintd.enable = true;
  services.accounts-daemon.enable = true;
  security.pam.services = {
    login.fprintAuth = true;
    sudo.fprintAuth = true;
    sddm.fprintAuth = true;
  };

  my.plasma.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  graphicalTablet.enable = true;
  virt.kvm.enable = true;
  virt.vbox.enable = false;
  container.docker.enable = true;

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
  ];

  programs.zsh.enable = true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "bak";
  home-manager.sharedModules = [
    nixvim.homeModules.nixvim
    plasma-manager.homeModules.plasma-manager
  ];
  home-manager.extraSpecialArgs = { inherit nur; };
  home-manager.users.kira = import ../../home/kira/home.nix;
}
