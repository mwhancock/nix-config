{ pkgs, ... }:
{
  programs.nixvim = {
    extraPackages = with pkgs; [
      jdt-language-server
      clang-tools
      pyright
      black
      stylua
      prettierd
      nodePackages.bash-language-server
      ripgrep
      fd
      fzf
    ];

    plugins = {
      # LSP
      lsp = {
        enable = true;
        servers = {
          clangd.enable = true;
          pyright.enable = true;
          jdtls.enable = true;
          bashls.enable = true;
          lua_ls.enable = true;
        };
      };

      # Completion
      cmp = {
        enable = true;
        settings = {
          sources = [
            { name = "nvim_lsp"; }
            { name = "buffer"; }
            { name = "path"; }
            { name = "luasnip"; }
          ];
          mapping = {
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.abort()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          };
        };
      };

      # Snippets
      luasnip.enable = true;
      cmp_luasnip.enable = true;

      # Formatting
      conform-nvim = {
        enable = true;
        settings = {
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

      # LSP lines - shows diagnostics inline
      lsp-lines.enable = true;
    };
  };
}
