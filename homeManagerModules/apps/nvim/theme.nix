{ ... }:
{
  programs.nvf.settings.vim.theme = {
    enable = true;
    name = "gruvbox";
    style = "dark";
    transparent = false; 
    extraConfig = ''
      -------------------------------------------------------------------------
      -- 1. RAINBOW INDENT HIGHLIGHTS
      -------------------------------------------------------------------------
      vim.api.nvim_set_hl(0, "IndentBlanklineRed",    { fg = "#cc241d" })
      vim.api.nvim_set_hl(0, "IndentBlanklineOrange", { fg = "#d65d0e" })
      vim.api.nvim_set_hl(0, "IndentBlanklineYellow", { fg = "#d79921" })
      vim.api.nvim_set_hl(0, "IndentBlanklineGreen",  { fg = "#689d6a" })
      vim.api.nvim_set_hl(0, "IndentBlanklineBlue",   { fg = "#458588" })
      vim.api.nvim_set_hl(0, "IndentBlanklinePurple", { fg = "#b16286" })
      vim.api.nvim_set_hl(0, "IndentBlanklineCurrent",{ fg = "#fabd2f", bold = true })

      -------------------------------------------------------------------------
      -- 2. MINIMAP INTEGRATION
      -------------------------------------------------------------------------
      -- Background of the map (slightly darker for depth)
      vim.api.nvim_set_hl(0, "MiniMapNormal", { fg = "#928374", bg = "#1d2021" }) 
      -- The "You are here" symbol (Gruvbox Aqua)
      vim.api.nvim_set_hl(0, "MiniMapSymbolCurrent", { fg = "#83a598", bold = true })
      -- Search results in the map (Gruvbox Yellow)
      vim.api.nvim_set_hl(0, "MiniMapSymbolSearch", { fg = "#fabd2f", bg = "#665c54" })

      -------------------------------------------------------------------------
      -- 3. NEO-TREE GIT INDICATORS
      -------------------------------------------------------------------------
      vim.api.nvim_set_hl(0, "NeoTreeGitModified",  { fg = "#fabd2f" })
      vim.api.nvim_set_hl(0, "NeoTreeGitUntracked", { fg = "#b8bb26" })
      vim.api.nvim_set_hl(0, "NeoTreeGitStaged",    { fg = "#83a598" })
      vim.api.nvim_set_hl(0, "NeoTreeGitDeleted",   { fg = "#fb4934" })
      vim.api.nvim_set_hl(0, "NeoTreeGitRenamed",   { fg = "#fe8019" })
      vim.api.nvim_set_hl(0, "NeoTreeGitIgnored",   { fg = "#928374" })
      vim.api.nvim_set_hl(0, "NeoTreeGitConflict",  { fg = "#fb4934" })
    '';
  };
}
