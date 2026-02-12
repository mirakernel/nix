{ config, lib, pkgs, ... }: {
  options.my.hm.python = {
    enable = lib.mkEnableOption "настройка Python для пользователя";
  };

  config = lib.mkIf config.my.hm.python.enable {
    home.packages = with pkgs; [
      python3
      uv
      ruff
      black
      isort
      mypy
      pyright
      pytest
      poetry
      pipx
      python3Packages.virtualenv
    ];
  };
}
