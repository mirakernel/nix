{ ... }: {
  programs.git = {
    enable = true;
    lfs.enable = true;

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;
      core.editor = "nvim";
    };
  };
}
