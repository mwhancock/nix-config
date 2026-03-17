{ pkgs, ... }:
{
  programs.nvf.settings.vim = {
    extraPackages = with pkgs; [
      gnumake
    ];

    extraPlugins = with pkgs.vimPlugins; {
      avante = {
        package = avante-nvim;
        setup = ''
          require("avante").setup({
            provider = "copilot",
            providers = {
              copilot = {
                model = "gpt-4o",
              },
              },
            },
            mappings = {
              submit = {
                normal = "<CR>",
                insert = "<C-s>",
              },
            },
          })
        '';
      };

      copilot-lua = {
        package = copilot-lua;
        setup = ''
          require("copilot").setup({
            suggestion = { enabled = false },
            panel = { enabled = false },
          })
        '';
      };
    };
  };
}
