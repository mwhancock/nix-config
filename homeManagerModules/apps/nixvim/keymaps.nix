{ ... }:
{
  programs.nixvim.keymaps = [
    # General
    {
      mode = "n";
      key = "<leader>Q";
      action = "<cmd>qa<cr>";
      options.desc = "Quit All";
    }
    {
      mode = "n";
      key = "<leader>qq";
      action = "<cmd>qa!<cr>";
      options.desc = "Force Quit All";
    }

    # File tree
    {
      mode = "n";
      key = "<leader>e";
      action = "<cmd>Neotree toggle<cr>";
      options.desc = "Toggle File Tree";
    }
    {
      mode = "n";
      key = "<leader>E";
      action = "<cmd>Neotree focus<cr>";
      options.desc = "Focus File Tree";
    }

    # Minimap
    {
      mode = "n";
      key = "<leader>mm";
      action = "<cmd>lua MiniMap.toggle()<cr>";
      options.desc = "Toggle Minimap";
    }

    # Terminal
    {
      mode = "n";
      key = "<C-\\>";
      action = "<cmd>ToggleTerm direction=horizontal<cr>";
      options.desc = "Terminal Bottom";
    }
    {
      mode = "n";
      key = "<leader>tv";
      action = "<cmd>ToggleTerm direction=vertical<cr>";
      options.desc = "Terminal Right";
    }
    {
      mode = "n";
      key = "<leader>tf";
      action = "<cmd>ToggleTerm direction=float<cr>";
      options.desc = "Terminal Float";
    }

    # Window navigation
    {
      mode = "n";
      key = "<C-h>";
      action = "<C-w>h";
      options.desc = "Move to left window";
    }
    {
      mode = "n";
      key = "<C-j>";
      action = "<C-w>j";
      options.desc = "Move to lower window";
    }
    {
      mode = "n";
      key = "<C-k>";
      action = "<C-w>k";
      options.desc = "Move to upper window";
    }
    {
      mode = "n";
      key = "<C-l>";
      action = "<C-w>l";
      options.desc = "Move to right window";
    }

    # Move lines
    {
      mode = "n";
      key = "<A-j>";
      action = "<cmd>m .+1<cr>==";
      options.desc = "Move line down";
    }
    {
      mode = "n";
      key = "<A-k>";
      action = "<cmd>m .-2<cr>==";
      options.desc = "Move line up";
    }
    {
      mode = "v";
      key = "<A-j>";
      action = ":m '>+1<cr>gv=gv";
      options.desc = "Move selection down";
    }
    {
      mode = "v";
      key = "<A-k>";
      action = ":m '<-2<cr>gv=gv";
      options.desc = "Move selection up";
    }
  ];
}
