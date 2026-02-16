{ config, lib, pkgs, ... }: {
  options.my.hm.shell = {
    enable = lib.mkEnableOption "настройка shell окружения";
  };

  config = lib.mkIf config.my.hm.shell.enable {
    home.packages = with pkgs; [
      ripgrep
      bat
      eza
      zoxide
      jq
      wget
    ];

    programs.zoxide.enable = true;

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
        codex = "ALL_PROXY='socks5h://localhost:2080' HTTPS_PROXY='socks5h://localhost:2080' HTTP_PROXY='http://localhost:2080' codex";
        proxy = "export ALL_PROXY='socks5h://localhost:2080' all_proxy='socks5h://localhost:2080' HTTPS_PROXY='socks5h://localhost:2080' https_proxy='socks5h://localhost:2080' HTTP_PROXY='http://localhost:2080' http_proxy='http://localhost:2080'";
        grep = "rg";
        cat = "bat";
        ls = "eza";
        cd = "z";
      };
    };
  };
}
