{ inputs, ... }:
{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./options.nix
    ./keymaps.nix
    ./ui.nix
    ./editor.nix
    ./lsp.nix
    ./treesitter.nix
    #./ai.nix
    ./git.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    colorschemes.gruvbox = {
      enable = true;
      settings.contrast_dark = "hard";
    };
  };

  programs.nixvim.extraConfigLua = ''
        vim.api.nvim_set_hl(0, "Cursor", { fg = "#1d2021", bg = "#fe8019"})
        vim.api.nvim_set_hl(0, "iCursor", { fg = "#1d2021", bg = "#b8bb26"})
        -- Set leader key
        vim.g.mapleader = " "
        vim.g.maplocalleader = " "
        vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

          vim.api.nvim_create_autocmd({"VimResized", "VimEnter"}, {
          callback = function()
            local cols = vim.o.columns
            local percent
            if cols < 100 then
              percent = 0.80  -- small window, 80%
            elseif cols < 160 then
              percent = 0.75  -- medium window, 75%
            else
              percent = 0.66  -- large/fullscreen, 66%
            end
            vim.opt.colorcolumn = tostring(math.floor(cols * percent))
          end,
    })

    -- Open neo-tree on startup
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        if vim.fn.argc() == 0 then
          vim.defer_fn(function()
            require("neo-tree.command").execute({ action = "show" })
          end, 100)
        end
      end,
    })

    -- Open minimap on startup
    vim.defer_fn(function()
      local map = require("mini.map")
      map.setup ({
                integrations = {
                    map.gen_integration.builtin_search(),
                    map.gen_integration.diagnostic(),
                    map.gen_integration.gitsigns(),
                    map.gen_integration.diff(),
                },
                window = {
                    side = "right",
                    width = 10,
                    winblend = 0,
                },
            })
      map.open()
    end, 200)
  '';
}
