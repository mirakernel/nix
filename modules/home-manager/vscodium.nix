{ config, lib, pkgs, ... }: {
  options.my.hm.vscodium = {
    enable = lib.mkEnableOption "настройка VSCodium";
  };

  config = lib.mkIf config.my.hm.vscodium.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      profiles.default = {
        extensions = with pkgs.vscode-extensions; [
          ms-ceintl.vscode-language-pack-ru
          # Rust
          rust-lang.rust-analyzer
          tamasfe.even-better-toml
          fill-labs.dependi
          vscodevim.vim
          vadimcn.vscode-lldb
          # Python
          ms-python.python
          ms-python.vscode-pylance
          ms-python.debugpy
          ms-python.black-formatter
          charliermarsh.ruff
        ];
        userSettings = {
          "update.mode" = "none";
          "telemetry.telemetryLevel" = "off";
          "extensions.autoUpdate" = false;
          "extensions.autoCheckUpdates" = false;
          "files.trimTrailingWhitespace" = true;
          "editor.formatOnSave" = true;
          "editor.fontFamily" = "JetBrainsMono Nerd Font";
        };
      };
    };

    xdg.configFile."VSCodium/User/locale.json".text = ''
      {
        "locale": "ru"
      }
    '';
  };
}
