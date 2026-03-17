{ config, lib, ... }: {
  options.my.hm.ssh = {
    enable = lib.mkEnableOption "ssh client конфиг";
  };

  config = lib.mkIf config.my.hm.ssh.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks."*" = {
        forwardAgent = false;
        addKeysToAgent = "no";
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };
      matchBlocks."product.studio" = {
        hostname = "93.189.229.156";
        user = "developer_dmitriy";
        identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
        extraOptions = {
          TCPKeepAlive = "yes";
        };
      };
      matchBlocks."mysql-tunnel" = {
        hostname = "93.189.229.156";
        user = "developer_dmitriy";
        identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
        identitiesOnly = true;
        localForwards = [
          {
            bind.address = "0.0.0.0";
            bind.port = 3306;
            host.address = "127.0.0.1";
            host.port = 3306;
          }
        ];
        serverAliveInterval = 30;
        serverAliveCountMax = 3;
      };
    };
  };
}
