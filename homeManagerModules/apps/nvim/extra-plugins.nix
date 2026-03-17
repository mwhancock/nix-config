{ pkgs, ... }:
{
  programs.nvf.settings.vim.extraPlugins = with pkgs.vimPlugins; {
    mini-map = {
      package = mini-nvim;
      setup = ''
        local map = require("mini.map")
        map.setup({
          integrations = {
            map.gen_integration.builtin_search(),
            map.gen_integration.diagnostic(),
            map.gen_integration.diff(),
            map.gen_integration.gitsigns(),
          },
          symbols = {
            encode = map.gen_encode_symbols.dot("4x2"),
          },
          window = {
            side = "right",
            width = 10,
            winblend = 0,
          },
        })
        map.open()

        vim.keymap.set("n", "<leader>mm", function()
          map.toggle()
        end, { desc = "Toggle Minimap" })
      '';
    };

    harpoon = {
      package = harpoon2;
      setup = ''
        require("harpoon"):setup({})
      '';
    };

    vim-illuminate = {
      package = vim-illuminate;
      setup = ''
        require("illuminate").configure({})
      '';
    };
  };
}
