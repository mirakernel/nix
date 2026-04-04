{ config, lib, pkgs, ... }:
let
  directusEnvSnippet =
    if lib.hasAttrByPath [ "sops" "templates" "directus-mcp.env" ] config
    then "if [ -f ${config.sops.templates."directus-mcp.env".path} ]; then set -a; . ${config.sops.templates."directus-mcp.env".path}; set +a; fi; "
    else "";
in {
  options.my.hm.shell = {
    enable = lib.mkEnableOption "настройка shell окружения";
  };

  config = lib.mkIf config.my.hm.shell.enable {
    home.sessionPath = [
      "${config.home.homeDirectory}/.nix-profile/bin"
      "/etc/profiles/per-user/${config.home.username}/bin"
      "/nix/var/nix/profiles/default/bin"
      "/run/current-system/sw/bin"
    ];

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
      initContent = lib.mkBefore ''
        export PATH="$HOME/.nix-profile/bin:/etc/profiles/per-user/${config.home.username}/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:$PATH"

        if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
          . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
        fi
      '';
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" ];
        theme = "robbyrussell";
      };
      shellAliases = {
        cdx = "codex";
        codex = "${directusEnvSnippet}NO_PROXY='localhost,127.0.0.1,::1' no_proxy='localhost,127.0.0.1,::1' ALL_PROXY='socks5h://localhost:2080' HTTPS_PROXY='socks5h://localhost:2080' HTTP_PROXY='http://localhost:2080' codex";
        claude = "HTTP_PROXY='http://127.0.0.1:2080' NO_PROXY='localhost .tms.ru' claude";
        proxy = "export ALL_PROXY='socks5h://localhost:2080' all_proxy='socks5h://localhost:2080' HTTPS_PROXY='socks5h://localhost:2080' https_proxy='socks5h://localhost:2080' HTTP_PROXY='http://localhost:2080' http_proxy='http://localhost:2080'";
        "mysql-tunnel" = "ssh -fN mysql-tunnel";
        grep = "rg";
        cat = "bat";
        ls = "eza";
        cd = "z";
      };
    };
  };
}
