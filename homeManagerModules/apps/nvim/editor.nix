{ ... }:
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
        size = 15;
        shade_terminals = true;
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
