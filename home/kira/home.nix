{ pkgs, lib, ... }: {
  home.username = "kira";
  home.homeDirectory = "/home/kira";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
    shellAliases = {
      cdx = "codex";
    };
  };

  home.packages = lib.optionals (pkgs ? codex) [ pkgs.codex ];
}
