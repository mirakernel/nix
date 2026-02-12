{ config, lib, pkgs, ... }: {
  options.my.hm.tor = {
    enable = lib.mkEnableOption "пользовательский Tor (SOCKS5 на 127.0.0.1:9050)";
  };

  config = lib.mkIf config.my.hm.tor.enable {
    home.packages = with pkgs; [
      tor
      torsocks
    ];

    xdg.configFile."tor/torrc".text = ''
      SocksPort 127.0.0.1:9050
      ControlPort 127.0.0.1:9051
      CookieAuthentication 1
      DataDirectory ${config.xdg.dataHome}/tor
      Log notice stdout
    '';

    systemd.user.services.tor = {
      Unit = {
        Description = "Tor daemon (user service)";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Service = {
        ExecStart = "${pkgs.tor}/bin/tor -f %h/.config/tor/torrc";
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
