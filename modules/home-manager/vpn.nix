{ pkgs, ... }: {
  home.packages = with pkgs; [
    throne
  ];
}
