# -----------------------------------------------------------------------------
# MODULE: NEOVIM (NVF) MASTER CONFIGURATION
# Description: Main entry point for the Neovim flake. 
# Imports all sub-modules and sets global editor behavior.
# -----------------------------------------------------------------------------
{ pkgs, ... }:
{
  imports = [
    ./ai.nix            # Avante / Copilot
    ./dap.nix           # Debugger (lldb/java)
    ./editor.nix        # Basic editor settings (indentation, etc)
    ./extra-plugins.nix # Manual plugin additions
    ./git.nix           # Gitsigns / Diffview
    ./keymaps.nix       # Global keybindings
    ./lsp.nix           # Language Server Protocol & Completion
    ./lua.nix           # Custom Lua logic & School PDF export
    ./theme.nix         # Gruvbox / Theme settings
    ./treesitter.nix    # Syntax highlighting
    ./ui.nix            # Lualine / Bufferline / Alpha
  ];

  programs.nvf = {
    enable = true;
    
    # Wrap settings in the 'vim' attribute as required by nvf
    settings.vim = {
      # 1. CORE ALIASES
      viAlias = true;
      vimAlias = true;

      # 2. SYSTEM INTEGRATION
      useSystemClipboard = true;
      preventJunkFiles = true; # No swap files cluttering your school work
      
      # 3. GLOBAL SETTINGS
      globals.mapleader = " "; # Ensure space is the leader for Which-Key
      
      # 4. DEFAULT SEARCH/UI BEHAVIOR
      searchCase = "smart";
      lineNumbers = true;
      relativeLineNumbers = true;
      cursorline = true;
      
      # 5. ASSIGNMENT ENGINE SUPPORT
      # Ensuring these are available for your Pandoc/Tectonic exports
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
