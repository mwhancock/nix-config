{ pkgs, ... }:
{
  programs.nixvim.plugins = {
    treesitter = {
      enable = true;
      settings = {
        highlight.enable = true;
        indent.enable = true;
        incremental_selection.enable = true;
      };
      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        c
        cpp
        java
        python
        lua
        nix
        bash
        json
        yaml
        toml
        markdown
        markdown_inline
      ];
    };

    # Treesitter context - shows current function/class at top of screen
    treesitter-context.enable = true;

    # Treesitter text objects - select functions, classes etc
    treesitter-textobjects = {
      enable = true;
      settings = {

      select = {
        enable = true;
        lookahead = true;
        keymaps = {
          "af" = "@function.outer";
          "if" = "@function.inner";
          "ac" = "@class.outer";
          "ic" = "@class.inner";
          "aa" = "@parameter.outer";
          "ia" = "@parameter.inner";
        };
      };
      move = {
        enable = true;
        gotoNextStart = {
          "]f" = "@function.outer";
          "]c" = "@class.outer";
        };
        gotoPreviousStart = {
          "[f" = "@function.outer";
          "[c" = "@class.outer";
        };
      };
      };
    };
  };
}
