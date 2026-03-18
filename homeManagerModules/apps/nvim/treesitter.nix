{ pkgs, ... }:
{
  programs.nvf.settings.vim = {
    treesitter = {
      enable = true;
      grammars = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
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
        markdown-inline
      ];
    };

    extraPlugins = with pkgs.vimPlugins; {
      treesitter-context = {
        package = nvim-treesitter-context;
        setup = ''
          require("treesitter-context").setup({})
        '';
      };
      treesitter-textobjects = {
        package = nvim-treesitter-textobjects;
        setup = ''
          require("nvim-treesitter-textobjects").setup({
            select = {
              enable = true,
              lookahead = true,
              keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
              },
            },
            move = {
              enable = true,
              goto_next_start = {
                ["]f"] = "@function.outer",
                ["]c"] = "@class.outer",
              },
              goto_previous_start = {
                ["[f"] = "@function.outer",
                ["[c"] = "@class.outer",
              },
            },
          })
        '';
      };
    };
  };
}
