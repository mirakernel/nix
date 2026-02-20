{ config, lib, pkgs, ... }: {
  home.packages = with pkgs;
    [
      telegram-desktop
      obsidian
      sweethome3d.application
    ]
    ++ lib.optionals (lib.attrByPath [ "my" "hm" "plasma" "enable" ] false config) [
      pkgs.kdePackages.krdc
    ];
}
