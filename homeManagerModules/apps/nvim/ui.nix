{lib, ...}: {
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
      theme = lib.generators.mkLuaInline ''
        (function()
          local custom_gruvbox = require('lualine.themes.gruvbox')

               custom_gruvbox.insert.a.bg = '#b8bb26'

               custom_gruvbox.visual.a.bg = '#d65d0e'

          return custom_gruvbox
        end)()
      '';
    };

    tabline.nvimBufferline.enable = true;

    notify.nvim-notify.enable = true;
    dashboard.alpha.enable = true;

    binds.whichKey = {
      enable = true;
      setupOpts = {
        delay = 300;
        win = {
          border = "rounded";
          padding = [1 2];
          row = -1;
        };
        layout.spacing = 3;
        triggers = [
          {
            mode = "nxsot";
            prefix = "<leader>";
          }
        ];
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
