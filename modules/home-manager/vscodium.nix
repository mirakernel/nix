{ config, lib, pkgs, ... }:
let
  cfg = config.my.hm.vscodium;
  proxySettings = lib.filterAttrs (_: value: value != null) {
    "http.proxy" = cfg.proxy.http;
    "http.proxyStrictSSL" = cfg.proxy.strictSSL;
    "http.proxyAuthorization" = cfg.proxy.authorization;
    "http.noProxy" = cfg.proxy.noProxy;
    "http.proxySupport" = cfg.proxy.support;
    "http.systemCertificates" = cfg.proxy.systemCertificates;
  };
in
{
  options.my.hm.vscodium = {
    enable = lib.mkEnableOption "настройка VSCodium";
    proxy = {
      http = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Прокси URL для VSCodium, например http://127.0.0.1:7890.";
      };
      strictSSL = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Проверять SSL-сертификаты при работе через proxy.";
      };
      authorization = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Значение заголовка Proxy-Authorization.";
      };
      noProxy = lib.mkOption {
        type = lib.types.nullOr (lib.types.listOf lib.types.str);
        default = null;
        description = "Список хостов/доменов, которые обходят proxy.";
      };
      support = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum [ "off" "on" "fallback" "override" ]);
        default = null;
        description = "Режим использования proxy в VSCodium.";
      };
      systemCertificates = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Использовать системные сертификаты для proxy.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      profiles.default = {
        extensions =
          (with pkgs.vscode-extensions; [
            ms-ceintl.vscode-language-pack-ru
            # Nix / NixOS / Flakes
            bbenoist.nix
            jnoortheen.nix-ide
            mkhl.direnv
            # Rust
            rust-lang.rust-analyzer
            tamasfe.even-better-toml
            fill-labs.dependi
            vscodevim.vim
            vadimcn.vscode-lldb
            # Python
            ms-python.python
            ms-pyright.pyright
            ms-python.debugpy
            ms-python.black-formatter
            charliermarsh.ruff
            # AI
            saoudrizwan.claude-dev
          ])
          ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            {
              name = "kivy-vscode";
              publisher = "BattleBas";
              version = "0.5.5";
              sha256 = "sha256-wcf1AxKLcS8tWUcRgrQw5tq1H6cNCGkfhHWjmZzxkNs=";
            }
          ];
        userSettings = {
          "update.mode" = "none";
          "telemetry.telemetryLevel" = "off";
          "extensions.autoUpdate" = false;
          "extensions.autoCheckUpdates" = false;
          "files.trimTrailingWhitespace" = true;
          "editor.formatOnSave" = true;
          "editor.fontFamily" = "JetBrainsMono Nerd Font";
          # Python
          "python.analysis.typeCheckingMode" = "basic";
          "python.analysis.autoImportCompletions" = true;
          "python.analysis.diagnosticMode" = "workspace";
          "python.analysis.useLibraryCodeForTypes" = true;
          "[python]" = {
            "editor.defaultFormatter" = "ms-python.black-formatter";
            "editor.codeActionsOnSave" = {
              "source.fixAll.ruff" = "explicit";
              "source.organizeImports.ruff" = "explicit";
            };
          };
        } // proxySettings;
      };
    };

    xdg.configFile."VSCodium/User/locale.json".text = ''
      {
        "locale": "ru"
      }
    '';
  };
}
