{ ... }:
{
  programs.nvf.settings.vim = {
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
    lsp = {
      enable = true;
      lspkind.enable = true;
      lightbulb.enable = true;
      trouble.enable = true;
      lspSignature.enable = true;
      servers = {
        clangd.enable = true;
        pyright.enable = true;
        java-language-server.enable = true;
        bash-language-server.enable = true;
        lua-ls.enable = true;
        nil.enable = true;
                nixd.enable = true;
      };
    };
    autocomplete.nvim-cmp = {
      enable = true;
    };
    snippets.luasnip.enable = true;
    formatter = {
      conform-nvim = {
        enable = true;
        setupOpts = {
          format_on_save = {
            timeout_ms = 500;
            lsp_fallback = true;
          };
          formatters_by_ft = {
            python = [ "black" ];
            c = [ "clang_format" ];
            cpp = [ "clang_format" ];
            java = [ "clang_format" ];
            lua = [ "stylua" ];
            nix = [ "nixpkgs_fmt" ];
          };
        };
      };
    };
  };
}
