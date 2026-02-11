{ pkgs, ... }: {
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    globals.mapleader = ",";
    globals.maplocalleader = ",";

    opts = {
      number = true;
      relativenumber = true;
      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
    };

    plugins = {
      lualine.enable = true;
      web-devicons.enable = true;
      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
      };
      lsp = {
        enable = true;
        servers.nil_ls.enable = true;
      };
      cmp = {
        enable = true;
        autoEnableSources = true;
      };
    };

    extraPackages = with pkgs; [
      nixfmt-rfc-style
    ];

    keymaps = [
      {
        key = "<leader>f";
        action = "<cmd>lua vim.lsp.buf.format()<CR>";
        mode = "n";
        options.silent = true;
      }
    ];
  };
}
