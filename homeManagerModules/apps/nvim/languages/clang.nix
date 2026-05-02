{...}: {
  programs.nvf.settings.vim.languages = {
    clang = {
      enable = true;
      lsp.servers = ["clangd"];
    };
  };
}
