{ inputs, pkgs, ... }:
{
  imports = [
    inputs.nvf.homeManagerModules.default
    ./theme.nix
    ./lsp.nix
    ./ui.nix
    ./editor.nix
    ./treesitter.nix
    ./git.nix
    ./keymaps.nix
    #./ai.nix
    ./dap.nix
    ./lua.nix
    ./extra-plugins.nix
  ];

  programs.nvf = {
    enable = true;
    settings.vim = {
      viAlias = true;
      vimAlias = true;


      options = {
        number = true;
        relativenumber = true;
        tabstop = 4;
        shiftwidth = 4;
        expandtab = true;
        smartindent = true;
        wrap = false;
        scrolloff = 8;
        signcolumn = "yes";
        updatetime = 50;
        swapfile = false;
        termguicolors = true;
        clipboard = "unnamedplus";
        colorcolumn = "80";
      };

      globals = {
        mapleader = " ";
        maplocalleader = " ";
      };

      extraPackages = with pkgs; [
        lazygit
        nil
        nixd
        ripgrep
        fd
        fzf
        clang-tools
        pyright
        black
        stylua
        gnumake
        jdt-language-server
        nodePackages.bash-language-server
      ];
    };
  };
}
