{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.hack
    nerd-fonts.ubuntu
    nerd-fonts.ubuntu-mono
  ];
}
