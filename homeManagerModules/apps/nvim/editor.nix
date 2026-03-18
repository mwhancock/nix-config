{ lib, ... }:
{
  programs.nvf.settings.vim = {
    filetree.neo-tree = {
      enable = true;
      setupOpts = {
        filesystem = {
          hijack_netrw_behavior = "open_current";
          use_libuv_file_watcher = true;
          bind_to_cwd = true;
        };
        window = {
          width = 30;
          mappings = {
            "<cr>" = "open";
            "l" = "open";
            "h" = "close_node";
          };
        };
      };
    };

    telescope = {
      enable = true;
    };

    terminal.toggleterm = {
      enable = true;
      lazygit.enable = true;
      mappings.open = "<C-\\>";
      setupOpts = {
        direction = "horizontal";
        shade_terminals = true;
        size = lib.generators.mkLuaInline ''
          function(term)
            if term.direction == "horizontal" then
              return 15
            elseif term.direction == "vertical" then
              return math.floor(vim.o.columns * 0.4)
            end
          end
        '';
      };
    };
    autopairs.nvim-autopairs.enable = true;

    comments.comment-nvim.enable = true;

    projects.project-nvim = {
      enable = true;
    };

    autocomplete.nvim-cmp.enable = true;
  };
}
