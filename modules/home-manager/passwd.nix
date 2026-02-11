{ pkgs, ... }: {
  home.packages = with pkgs; [
    keepassxc
    bitwarden-desktop
  ];
}
