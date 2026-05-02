{...}: {
  programs.nvf.settings.vim.languages = {
    markdown = {
      enable = true;
      extensions = {
        render-markdown-nvim.enable = true;
      };
    };
  };
}
