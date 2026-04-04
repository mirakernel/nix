{ config, lib, ... }:
let
  cfg = config.my.hm.git;
in
{
  options.my.hm.git = {
    enable = lib.mkEnableOption "настройка Git";
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      lfs.enable = true;

      settings = {
        init.defaultBranch = "main";
        pull.rebase = false;
        push.autoSetupRemote = true;
        core.editor = "nvim";
        user = {
          name = "Mirakernel";
          email = "mirakernel@disroot.org";
        };
      };
    };
  };
}
