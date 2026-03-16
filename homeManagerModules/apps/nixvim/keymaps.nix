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

    #Harpoon
    {
      mode = "n";
      key = "<leader>ha";
      action.__raw = ''function() require("harpoon"):list():add() end'';
      options.desc = "Harpoon Add File";
    }
    {
      mode = "n";
      key = "<leader>hh";
      action.__raw = ''function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end'';
      options.desc = "Harpoon Menu";
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

    {
      mode = [ "n" "x" "o" ];
      key = "<leader>s";
      action.__raw = ''function() require("flash").jump() end'';
      options.desc = "Flash Jump";
    }

    #BufferLine
    {
      mode = "n";
      key = "<leader>bl";
      action = "<cmd>BufferLineMoveNext<cr>";
      options.desc = "Move Buffer Right";
    }
    {
      mode = "n";
      key = "<leader>bh";
      action = "<cmd>BufferLineMovePrev<cr>";
      options.desc = "Move Buffer Left";
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

    #LSP
    {
      mode = "n";
      key = "gd";
      action = "<cmd>lua vim.lsp.buf.definition()<cr>";
      options.desc = "Go to Definition";
    }
    {
      mode = "n";
      key = "gr";
      action = "<cmd>lua vim.lsp.buf.references()<cr>";
      options.desc = "References";
    }
    {
      mode = "n";
      key = "gi";
      action = "<cmd>lua vim.lsp.buf.implementation()<cr>";
      options.desc = "Go to Implementation";
    }
    {
      mode = "n";
      key = "K";
      action = "<cmd>lua vim.lsp.buf.hover()<cr>";
      options.desc = "Hover Docs";
    }
    {
      mode = "n";
      key = "<leader>ca";
      action = "<cmd>lua vim.lsp.buf.code_action()<cr>";
      options.desc = "Code Action";
    }
    {
      mode = "n";
      key = "<leader>rn";
      action = "<cmd>lua vim.lsp.buf.rename()<cr>";
      options.desc = "Rename";
    }
    {
      mode = "n";
      key = "[d";
      action = "<cmd>lua vim.diagnostic.goto_prev()<cr>";
      options.desc = "Prev Diagnostic";
    }
    {
      mode = "n";
      key = "]d";
      action = "<cmd>lua vim.diagnostic.goto_next()<cr>";
      options.desc = "Next Diagnostic";
    }

    {
      mode = "n";
      key = "<leader>op";
      action.__raw = ''
        function()
            local pdf = vim.fn.glob(vim.fn.getcwd() .. "/*.pdf")
            if pdf ~= "" then 
                vim.fn.jobstart({"zathura", pdf})
            end
            end
      '';
      options.desc = "Open PDF";
    }

  ];
}
