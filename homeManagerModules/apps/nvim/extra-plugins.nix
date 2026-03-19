{pkgs, ...}: {
  programs.nvf.settings.vim.extraPlugins = with pkgs.vimPlugins; {
    mini-map = {
      package = mini-nvim;
      setup = ''
        local map = require("mini.map")

        vim.api.nvim_set_hl(0, "MiniMapNormal", { fg = "#928374", bg = "#1d2021" })
        vim.api.nvim_set_hl(0, "MiniMapSymbolCurrent", { fg = "#83a598", bold = true })
        vim.api.nvim_set_hl(0, "MiniMapSymbolSearch", { fg = "#fabd2f", bg = "#665c54" })

        map.setup({
          integrations = {
            map.gen_integration.builtin_search(),
            map.gen_integration.diagnostic(),
            map.gen_integration.diff(),
            map.gen_integration.gitsigns(),
          },
          symbols = {
            encode = map.gen_encode_symbols.dot("4x2"),
            scroll_line = '█',
          },
          window = {
            side = "right",
            width = 10,
            winblend = 15,
            show_spawn_with_clean = true,
          },
        })
        map.open()

        vim.keymap.set("n", "<leader>mm", function()
          map.toggle()
        end, { desc = "Toggle Minimap" })
      '';
    };

    harpoon = {
      package = pkgs.vimPlugins.harpoon2;
      setup = ''
        local harpoon = require("harpoon")
        harpoon:setup({})

        vim.keymap.set("n", "<leader>ha", function()
          harpoon:list():add()
        end, { desc = "Harpoon Add File" })

        vim.keymap.set("n", "<leader>hh", function()
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end, { desc = "Harpoon Menu" })
      '';
    };

    vim-illuminate = {
      package = vim-illuminate;
      setup = ''
        require("illuminate").configure({})
      '';
    };
    flash = {
      package = pkgs.vimPlugins.flash-nvim;
      setup = ''
        require("flash").setup({})
        vim.keymap.set({ "n", "x", "o" }, "<leader>s", function()
          require("flash").jump()
        end, { desc = "Flash Jump" })
      '';
    };
    vim-surround = {
      package = pkgs.vimPlugins.vim-surround;
      setup = ''
      '';
    };
  };
}
