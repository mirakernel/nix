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
      pkgs.emacs
      pkgs.clojure
      pkgs.leiningen
      pkgs.babashka
      pkgs.jdk
      pkgs.sbcl
    ];

    xdg.configFile."emacs/init.el".text = ''
      (setq inhibit-startup-message t)
      (setq make-backup-files nil)
      (setq auto-save-default nil)

      (show-paren-mode 1)
      (electric-pair-mode 1)
      (global-company-mode 1)
      (global-display-line-numbers-mode 1)

      ;; Clojure
      (require 'clojure-mode)
      (require 'cider)
      (add-hook 'clojure-mode-hook #'paredit-mode)
      (add-hook 'clojure-mode-hook #'rainbow-delimiters-mode)
      (setq cider-repl-display-help-banner nil)

      ;; Common Lisp
      (require 'slime)
      (setq inferior-lisp-program "sbcl")
      (slime-setup '(slime-fancy))
    '';
  };
}
