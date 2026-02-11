{ pkgs, ... }: {

  programs.alacritty = {
    enable = true;
    settings = {
      terminal.shell = {
        program = "${pkgs.tmux}/bin/tmux";
        args = [ "new-session" "-A" "-s" "main" ];
      };
      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
        };
      };
      window = {
        opacity = 0.96;
      };
    };
  };

  home.packages = with pkgs; [ terminator ];
}
