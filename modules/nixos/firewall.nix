{ config, lib, ... }: {
  options.my.nixos.firewall.enable = lib.mkEnableOption "firewall";

  config = lib.mkIf config.my.nixos.firewall.enable {
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ 3000 3100 9000 10006 ];
      allowedUDPPorts = [ 3000 3100 9000 10006 ];
    };
  };
}
