{...}: {
  programs.nvf.settings.vim = {
    lsp = {
      enable = true;
      lspkind.enable = true;
      lightbulb.enable = true;
      trouble.enable = true;
      lspSignature.enable = true;
    };

    diagnostics = {
      enable = true;
      config = {
        virtual_text = false;
        virtual_lines = true;
        signs = true;
        underline = true;
        update_in_insert = false;
      };
    };

    languages = {
      enableTreesitter = true;
      enableFormat = true;
    };

    autocomplete.nvim-cmp.enable = true;
    snippets.luasnip.enable = true;

    formatter.conform-nvim = {
      enable = true;
      setupOpts = {
        format_on_save = {
          timeout_ms = 500;
          lsp_format = "fallback";
        };
      };
    };
  };
}
