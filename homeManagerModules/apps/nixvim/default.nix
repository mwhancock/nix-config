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
    ./ai.nix
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
    -- Set leader key
    vim.g.mapleader = " "
    vim.g.maplocalleader = " "
    vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })


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
      map.open()
    end, 200)
  '';
}
