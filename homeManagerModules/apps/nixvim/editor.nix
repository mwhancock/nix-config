{ ... }:
{
  programs.nixvim.plugins = {
    # File tree
    neo-tree = {
      enable = true;
      settings = {
        window =
          {
            width = 30;
          };
        filesystem = {
          hijack_netrw_behavior = "open_current";
          use_libuv_file_watcher = true;
          filtered_items = {
            visible = true;
          };
        };
        default_component_configs = {
          indent = {
            with_expanders = true;
            expander_collapsed = "";
            expander_expanded = "";
          };
        };
        window.mappings = {
          "<cr>" = "open";
          "l" = "open";
          "h" = "close_node";
        };
      };
    };

    programs.nixvim.extraConfigLua = ''
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          if vim.fn.argc() == 0 then
            vim.defer_fn(function()
              require("neo-tree.command").execute({ action = "show" })
            end, 100)
          end
        end,
      })
    '';

    # Fuzzy finder
    telescope = {
      enable = true;
      extensions = {
        fzf-native.enable = true;
      };
    };

    # Terminal

    toggleterm = {
      enable = true;
      settings = {
        open_mapping = "[[<c-\\>]]";
        direction = "horizontal";
        shade_terminals = true;
        size.__raw = ''
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

    # Auto pairs brackets
    nvim-autopairs.enable = true;

    # Surround text objects
    vim-surround.enable = true;

    # Comments
    comment.enable = true;

    # Flash jump
    flash.enable = true;

    # Trouble diagnostics
    trouble.enable = true;

    # Harpoon
    harpoon = {
      enable = true;
      enableTelescope = true;
    };
  };
}
