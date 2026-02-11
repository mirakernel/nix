{ ... }: {
  programs.floorp = {
    enable = true;

    policies = {
      DisableTelemetry = true;
      DisablePocket = true;
    };

    profiles.default = {
      isDefault = true;
      settings = {
        "browser.startup.page" = 3;
        "browser.startup.homepage" = "https://search.nixos.org/";
        "browser.newtabpage.enabled" = true;
        "privacy.donottrackheader.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
      };
    };
  };
}
