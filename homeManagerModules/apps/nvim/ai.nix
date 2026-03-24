{pkgs, ...}: {
  programs.nvf.settings.vim.extraPlugins = with pkgs.vimPlugins; {
    bullets-vim = {
      package = pkgs.vimPlugins.bullets-vim;
      setup = ''
        vim.g.bullets_enabled_filetypes = { 'markdown', 'text', 'gitcommit' }
        vim.g.bullets_outline_levels = { 'rom', 'std', 'num',}
        vim.keymap.set('i', '<Tab>', '<Plug>(bullets-demote)', { silent = true })
        vim.keymap.set('i', '<S-Tab>', '<Plug>(bullets-promote)', { silent = true })
      '';
    };

    copilot-lua = {
      package = copilot-lua;
      setup = "";
    };

    avante = {
      package = avante-nvim;
      setup = ''
        require("copilot").setup({
          suggestion = {
          enabled = true,
          auto_trigger = true,
          hide_during_completion = true,
          keymap = {
              accept = "<M-l>",
              accept_word = "<C-Right>",
              accept_line = "<C-Down>",
              next = "<M-]>",
              prev = "<M-[>",
              dismiss = "<C-e>",
              },
          },
          panel = { enabled = false },
        })
        require("avante_lib").load()
        require("avante").setup({
          provider = "copilot",
          auto_suggestions_provider = "copilot",
          providers = {
            copilot = {
              model = "gpt-4o",
            },
          },
          mappings = {
            submit = {
              normal = "<CR>",
              insert = "<C-s>",
            },
          },
        })
      '';
    };
  };
}
