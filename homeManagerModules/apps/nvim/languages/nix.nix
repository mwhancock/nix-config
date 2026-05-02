{...}: {
  programs.nvf.settings.vim.languages = {
    nix = {
      enable = true;
      lsp.servers = ["nixd"];
    };
  };
}
