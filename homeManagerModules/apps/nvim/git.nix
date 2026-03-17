{ pkgs, ... }:
{
  programs.nvf.settings.vim = {
    git = {
      enable = true;
      gitsigns = {
        enable = true;
        setupOpts = {
          current_line_blame = true;
          current_line_blame_opts = {
            delay = 500;
          };
          signs = {
            add.text = "▎";
            change.text = "▎";
            delete.text = "";
            topdelete.text = "";
            changedelete.text = "▎";
          };
        };
      };
    };

    extraPlugins = with pkgs.vimPlugins; {
      diffview = {
        package = diffview-nvim;
        setup = ''
          require("diffview").setup({})
        '';
      };
    };

    extraPackages = with pkgs; [
      lazygit
    ];
  };
}
