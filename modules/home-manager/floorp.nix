{ pkgs, nur, ... }:
let
  nurPkgs =
    if nur ? legacyPackages then
      nur.legacyPackages.${pkgs.system}
    else
      nur.packages.${pkgs.system};
  addons = nurPkgs.repos.rycee.firefox-addons;
in {
  programs.floorp = {
    enable = true;
    languagePacks = [ "ru-RU" ];

    policies = {
      DisableTelemetry = true;
      DisablePocket = true;
    };

    profiles.default = {
      isDefault = true;
      search = {
        force = true;
        default = "DuckDuckGo";
      };
      extensions = with addons; [
        ublock-origin
        tampermonkey
        bitwarden
      ];
      settings = {
        "browser.startup.page" = 3;
        "browser.startup.homepage" = "https://search.nixos.org/";
        "browser.newtabpage.enabled" = true;
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
  };
}
