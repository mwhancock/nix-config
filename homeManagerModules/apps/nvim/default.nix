# -----------------------------------------------------------------------------
# MODULE: NEOVIM (NVF) MASTER CONFIGURATION
# -----------------------------------------------------------------------------
{pkgs, ...}: {
  imports = [
    ./languages/default.nix
    ./ai.nix
    ./dap.nix
    ./editor.nix
    ./extra-plugins.nix
    ./git.nix
    ./keymaps.nix
    ./lsp.nix
    ./lua.nix
    ./theme.nix
    ./treesitter.nix
    ./ui.nix
  ];

  programs.nvf = {
    enable = true;
    settings.vim = {
      viAlias = true;
      vimAlias = true;
      clipboard.registers.unnamedplus = true;
      visuals.nvim-web-devicons.enable = true;
      extraPackages = with pkgs; [
        pandoc
        tectonic
        zathura
        ripgrep
        fd
      ];
    };
  };
}
