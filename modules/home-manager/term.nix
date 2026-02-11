{ pkgs, ... }: {
  programs.alacritty = {
    enable = true;
    settings = {
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
