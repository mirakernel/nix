{ pkgs, ... }: {
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal = {
          family = "JetBrains Mono";
        };
      };
      window = {
        opacity = 0.96;
      };
    };
  };

  home.packages = with pkgs; [ terminator ];
}
