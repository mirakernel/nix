{ ... }: {
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
}
