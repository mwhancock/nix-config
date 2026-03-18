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

      nix = {
        enable = true;
        lsp.servers = ["nixd"];
      };

      rust.enable = true;

      python = {
        enable = true;
        lsp.servers = ["pyright"];
        format.type = ["black"];
      };

      clang = {
        enable = true;
        lsp.servers = ["clangd"];
      };

      java.enable = true;
      bash.enable = true;
      lua.enable = true;
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
