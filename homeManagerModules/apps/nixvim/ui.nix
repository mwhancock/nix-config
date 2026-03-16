{ ... }:
{
  programs.nixvim.plugins = {
    # Status line
    lualine.enable = true;

    # Buffer tabs
    bufferline.enable = true;

    # Better UI for messages and cmdline
    noice.enable = true;

    # Indent guides
    indent-blankline.enable = true;

    # Highlight word under cursor
    illuminate.enable = true;

    # Minimap
    mini = {
      enable = true;
      modules = {
        map = {
          window = {
            side = "right";
            width = 10;
            winblend = 0;
          };
          integrations = {
            "__unkeyed-1" = {
              "__raw" = "require('mini.map').gen_integration.builtin_search()";
            };
            "__unkeyed-2" = {
              "__raw" = "require('mini.map').gen_integration.diagnostic()";
            };
            "__unkeyed-3" = {
              "__raw" = "require('mini.map').gen_integration.diff()";
            };
          };
        };
      };
    };

    web-devicons.enable = true;

    # Which key - shows keybind hints
    which-key = {
      enable = true;
      settings = {
        delay = 300;
        icons = {
          mappings = true;
          keys = {
            Space = "SPC";
            CR = "RET";
            Esc = "ESC";
            BS = "BS";
          };
        };
        win = {
          border = "rounded";
          padding = [ 1 2 ];
          row = -1;
        };
        layout = {
          spacing = 3;
        };
        triggers = [
          {
            __unkeyed-1 = "<leader>";
            mode = "nxsot";
          }
        ];
      };
    };
    # Better notifications
    notify.enable = true;

    # Colorizer - shows colors in code
    nvim-colorizer.enable = true;
  };

}
