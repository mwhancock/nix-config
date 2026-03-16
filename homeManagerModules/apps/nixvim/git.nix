{ pkgs, ... }:
{
  programs.nixvim = {
    extraPackages = with pkgs; [
      lazygit
    ];

    plugins = {
      # Git signs in gutter
      gitsigns = {
        enable = true;
        settings = {
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

      # Lazygit integration
      lazygit.enable = true;

      # Git diff view
      diffview.enable = true;
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>gg";
        action = "<cmd>LazyGit<cr>";
        options.desc = "LazyGit";
      }
      {
        mode = "n";
        key = "<leader>gd";
        action = "<cmd>DiffviewOpen<cr>";
        options.desc = "Git Diff";
      }
      {
        mode = "n";
        key = "<leader>gh";
        action = "<cmd>Gitsigns preview_hunk<cr>";
        options.desc = "Preview Hunk";
      }
      {
        mode = "n";
        key = "<leader>gb";
        action = "<cmd>Gitsigns blame_line<cr>";
        options.desc = "Blame Line";
      }
    ];
  };
}
