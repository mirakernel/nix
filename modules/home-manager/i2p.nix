{ config, lib, pkgs, ... }: {
  options.my.hm.i2p = {
    enable = lib.mkEnableOption "пользовательский i2pd (I2P router + локальные прокси)";
  };

  config = lib.mkIf config.my.hm.i2p.enable {
    home.packages = with pkgs; [ i2pd ];

    xdg.configFile."i2pd/i2pd.conf".text = ''
      daemon = false
      ipv4 = true
      ipv6 = false
      datadir = ${config.xdg.dataHome}/i2pd
      tunconf = ${config.xdg.configHome}/i2pd/tunnels.conf
      log = stdout

      [http]
      enabled = true
      address = 127.0.0.1
      port = 7070

      [httpproxy]
      enabled = true
      address = 127.0.0.1
      port = 4444

      [socksproxy]
      enabled = true
      address = 127.0.0.1
      port = 4447

      [sam]
      enabled = true
      address = 127.0.0.1
      port = 7656

      [i2cp]
      enabled = true
      address = 127.0.0.1
      port = 7654
    '';

    xdg.configFile."i2pd/tunnels.conf".text = "";

    systemd.user.services.i2pd = {
      Unit = {
        Description = "i2pd daemon (user service)";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Service = {
        ExecStart = "${pkgs.i2pd}/bin/i2pd --conf %h/.config/i2pd/i2pd.conf";
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
