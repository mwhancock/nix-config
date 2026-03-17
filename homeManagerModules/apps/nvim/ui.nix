{ ... }:
{
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
      theme = "gruvbox";
    };

    tabline.nvimBufferline.enable = true;

    notify.nvim-notify.enable = true;

    binds.whichKey = {
      enable = true;
      setupOpts = {
        delay = 300;
        win = {
          border = "rounded";
          padding = [ 1 2 ];
          row = -1;
        };
        layout.spacing = 3;
        triggers = [
          {
            __unkeyed-1 = "<leader>";
            mode = "nxsot";
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
      };
    };
  };
}
