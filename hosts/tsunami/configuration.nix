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
  i18n.defaultLocale = "ru_RU.UTF-8";
  i18n.supportedLocales = [ "ru_RU.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];

  console = {
    useXkbConfig = true;
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

  my.plasma.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;
  graphicalTablet.enable = true;
  virt.kvm.enable = true;
  virt.vbox.enable = false;
  container.docker.enable = true;

  users.users.kira = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.sharedModules = [
    nixvim.homeModules.nixvim
    plasma-manager.homeModules.plasma-manager
  ];
  home-manager.extraSpecialArgs = { inherit nur; };
  home-manager.users.kira = import ../../home/kira/home.nix;
}
