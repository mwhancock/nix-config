{...}: {
  programs.nvf.settings.vim = {
    ui = {
      borders = {
        enable = true;
        globalStyle = "rounded";
      };
      illuminate.enable = true;
      noice.enable = true;
      colorizer = {
        enable = true;
      };
    };

    statusline.lualine = {
      enable = true;
      theme = "gruvbox-material";
    };

    tabline.nvimBufferline.enable = true;

    notify.nvim-notify.enable = true;
    dashboard.alpha.enable = true;

    binds.whichKey = {
      enable = true;
      setupOpts = {
        preset = "modern";
        win = {
          border = "single";
          col = 999;
          row = 999;
          width = 0.3;
          padding = [1 2 1 2];
        };
        layout = {
          align = "left";
          spacing = 3;
        };
      };
    };
    spellcheck.enable = false;

    visuals = {
      nvim-scrollbar.enable = false;
      nvim-web-devicons.enable = true;
      indent-blankline = {
        enable = true;
        setupOpts = {
          indent = {
            char = "▎";
            highlight = [
              "IndentBlanklineRed"
              "IndentBlanklineOrange"
              "IndentBlanklineYellow"
              "IndentBlanklineGreen"
              "IndentBlanklineBlue"
              "IndentBlanklinePurple"
            ];
          };
          scope = {
            enabled = true;
            show_start = false;
            highlight = "IndentBlanklineCurrent";
          };
        };
      };
    };
  };
}
