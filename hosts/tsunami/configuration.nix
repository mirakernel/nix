{ pkgs, nixvim, nur, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/pantheon.nix
    ../../modules/nixos/virt.nix
    ../../modules/nixos/container.nix
    ../../modules/nixos/graphical-tablet.nix
  ];

  system.stateVersion = "25.11";
  i18n.defaultLocale = "ru_RU.UTF-8";
  i18n.supportedLocales = [ "ru_RU.UTF-8/UTF-8" "en_US.UTF-8/UTF-8" ];

  console = {
    useXkbConfig = true;
  };

  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:alt_shift_toggle";
  };

  boot.loader.grub.devices = [ "nodev" ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [
      "https://mirror.yandex.ru/nixos/"
      "https://cache.nixos.org/"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypb7GmY0+E5d8Xl8v8M8x0Gv6U="
    ];
  };

  my.pantheon.enable = true;
  graphicalTablet.enable = true;
  virt.kvm.enable = true;
  virt.vbox.enable = true;
  container.docker.enable = true;

  users.users.kira = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.sharedModules = [ nixvim.homeManagerModules.nixvim ];
  home-manager.extraSpecialArgs = { inherit nur; };
  home-manager.users.kira = import ../../home/kira/home.nix;
}
