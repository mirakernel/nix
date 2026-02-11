{ config, lib, pkgs, ... }: {
  options.my.hm.rust = {
    enable = lib.mkEnableOption "настройка Rust для пользователя";
  };

  config = lib.mkIf config.my.hm.rust.enable {
    home.packages = with pkgs; [
      rustc
      cargo
      rustfmt
      clippy
      rust-analyzer
      lldb
    ];

  };
}
