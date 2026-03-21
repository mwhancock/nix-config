{pkgs, ...}: {
  programs.nvf.settings.vim.extraPlugins = with pkgs.vimPlugins; {
    copilot-lua = {
      package = copilot-lua;
      setup = "";
    };

    avante = {
      package = avante-nvim;
      setup = ''
        require("copilot").setup({
          suggestion = { enabled = false },
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
