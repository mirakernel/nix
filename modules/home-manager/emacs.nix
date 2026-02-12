{ config, lib, pkgs, ... }: {
  options.my.hm.emacs = {
    enable = lib.mkEnableOption "настройка Emacs PGTK";
  };

  config = lib.mkIf config.my.hm.emacs.enable {
    programs.emacs = {
      enable = true;
      package = pkgs.emacs-pgtk;
      extraPackages = epkgs: with epkgs; [
        clojure-mode
        cider
        paredit
        rainbow-delimiters
        company
        slime
      ];
    };

    home.packages = [
      pkgs.clojure
      pkgs.leiningen
      pkgs.babashka
      pkgs.jdk
      pkgs.sbcl
    ];

    services.emacs = {
      enable = true;
      package = pkgs.emacs-pgtk;
    };

  };
}
