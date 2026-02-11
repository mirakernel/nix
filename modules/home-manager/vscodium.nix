{ config, lib, pkgs, ... }: {
  options.my.hm.vscodium = {
    enable = lib.mkEnableOption "настройка VSCodium";
  };

  config = lib.mkIf config.my.hm.vscodium.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      extensions = with pkgs.vscode-extensions; [
        ms-ceintl.vscode-language-pack-ru
        # Rust
        rust-lang.rust-analyzer
        tamasfe.even-better-toml
        serayuzgur.crates
        vadimcn.vscode-lldb
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

    xdg.configFile."VSCodium/User/locale.json".text = ''
      {
        "locale": "ru"
      }
    '';
  };
}
