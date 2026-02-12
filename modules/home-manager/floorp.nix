{ config, pkgs, nur, ... }:
let
  nurPkgs =
    if nur ? legacyPackages then
      nur.legacyPackages.${pkgs.stdenv.hostPlatform.system}
    else
      nur.packages.${pkgs.stdenv.hostPlatform.system};
  addons = nurPkgs.repos.rycee.firefox-addons;
in {
  programs.floorp = {
    enable = true;
    languagePacks = [ "ru" ];

    policies = {
      DisableTelemetry = true;
      DisablePocket = true;
    };

    profiles = {
      default = {
        isDefault = true;
        search = {
          force = true;
          default = "ddg";
        };
        extensions.packages = with addons; [
          ublock-origin
          violentmonkey
          bitwarden
        ];
        settings = {
          "browser.startup.page" = 3;
          "browser.startup.homepage" = "https://search.nixos.org/";
          "browser.newtabpage.enabled" = true;
          "browser.download.dir" = config.xdg.userDirs.download;
          "browser.download.folderList" = 2;
          "browser.download.useDownloadDir" = true;
          "privacy.donottrackheader.enabled" = true;
          "privacy.trackingprotection.enabled" = true;
          "network.proxy.type" = 1;
          "network.proxy.socks" = "localhost";
          "network.proxy.socks_port" = 2080;
          "network.proxy.socks_version" = 5;
          "network.proxy.socks_remote_dns" = true;
          "network.proxy.share_proxy_settings" = true;
        };
      };

      i2p = {
        id = 1;
        name = "I2P";
        search = {
          force = true;
          default = "ddg";
        };
        settings = {
          "browser.startup.page" = 1;
          "browser.startup.homepage" = "http://127.0.0.1:7070/";
          "browser.newtabpage.enabled" = true;
          "browser.download.dir" = config.xdg.userDirs.download;
          "browser.download.folderList" = 2;
          "browser.download.useDownloadDir" = true;
          "network.proxy.type" = 1;
          "network.proxy.http" = "127.0.0.1";
          "network.proxy.http_port" = 4444;
          "network.proxy.ssl" = "127.0.0.1";
          "network.proxy.ssl_port" = 4444;
          "network.proxy.socks" = "127.0.0.1";
          "network.proxy.socks_port" = 4447;
          "network.proxy.socks_version" = 5;
          "network.proxy.socks_remote_dns" = true;
          "network.proxy.no_proxies_on" = "localhost, 127.0.0.1";
          "network.proxy.share_proxy_settings" = false;
          "network.dns.disablePrefetch" = true;
          "privacy.trackingprotection.enabled" = true;
        };
      };
    };
  };
}
