{...}: {
  programs.nvf.settings.vim.languages = {
    python = {
        enable = true;
        lsp.servers = ["pyright"];
        format.type = ["black"];
      };
  };
  }
