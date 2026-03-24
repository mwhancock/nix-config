# -----------------------------------------------------------------------------
# MODULE: NEOVIM (NVF) MAIN CONFIGURATION
# Description: Entry point for the Neovim Flake (nvf) setup.
# -----------------------------------------------------------------------------
{...}: {
  imports = [
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
      useSystemClipboard = true;
    };
  };
}
