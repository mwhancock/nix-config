{...}: {
  programs.nvf.settings.vim.luaConfigRC.myConfig = ''
    -------------------------------------------------------------------------------
    -- 1. BASIC BEHAVIOR
    -------------------------------------------------------------------------------
    vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

    -- Terminal auto-insert
    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "*",
      callback = function()
        vim.cmd("startinsert")
      end,
    })

    -- Autosave on focus lost
    vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
      callback = function()
        if vim.bo.modified and not vim.bo.readonly and vim.fn.expand("%") ~= "" then
          vim.cmd("silent! write")
        end
      end,
    })

    -------------------------------------------------------------------------------
    -- 2. UI & DASHBOARD (ALPHA-NVIM)
    -------------------------------------------------------------------------------
    local status_ok, alpha = pcall(require, "alpha")
    if status_ok then
      local dashboard = require("alpha.themes.dashboard")
      dashboard.section.header.val = {
        [[                               __                ]],
        [[  ___     __    __   __   __  /\_\    ___ ___    ]],
        [[ /' _ `\ /'__`\/\ \ /\ \ /\ \ \/\ \  /' __` __`\  ]],
        [[ /\ \/\ \/\  __/\ \ \\ \ \ \ \ \ \ \ /\ \/\ \/\ \ ]],
        [[ \ \_\ \_\ \____\\ \____/ \ \_\ \ \_\\ \_\ \_\ \_\]],
        [[  \/_/\/_/\/____/ \/___/   \/_/  \/_/ \/_/\/_/\/_/]],
        [[                                                  ]],
        [[             -- THE GROOVY EDITOR --              ]],
      }
      dashboard.section.header.opts.hl = "Keyword"

      dashboard.section.buttons.val = {
        dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
        dashboard.button("f", "󰈞  Find file", ":Telescope find_files <CR>"),
        dashboard.button("r", "󰄉  Recent", ":Telescope oldfiles <CR>"),
        dashboard.button("s", "  Settings", ":e $MYVIMRC <CR>"),
        dashboard.button("q", "󰅚  Quit", ":qa<CR>"),
      }
      alpha.setup(dashboard.opts)
    end

    ------------------------------------------------------------------------------
    -- 3. PLUGINS & STARTUP BEHAVIOR
    -------------------------------------------------------------------------------
    -- Neo-tree on startup (only if opening a directory or no file)
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
            if vim.fn.argc() == 0 or vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
              vim.defer_fn(function()
            require("neo-tree.command").execute({ action = "show", position = "left" })
          end, 50)
        end
      end,
    })

    vim.api.nvim_create_autocmd("VimResized", {
      callback = function()
        local cols = vim.o.columns
        local width = cols < 100 and 20 or cols < 160 and 25 or 30
        pcall(require("neo-tree.command").execute, {
          action = "show",
          position = "left",
          width = width,
        })
      end,
    })

    local wk = require("which-key")
    wk.add({
      { "<leader>a", group = "Avante" },
      { "<leader>b", group = "Buffers" },
      { "<leader>d", group = "Debug" },
      { "<leader>e", group = "Explorer" },
      { "<leader>g", group = "Git" },
      { "<leader>h", group = "Harpoon" },
      { "<leader>l", group = "LSP" },
      { "<leader>m", group = "Minimap" },
      { "<leader>o", group = "Open" },
      { "<leader>r", group = "Rename" },
      { "<leader>s", group = "Flash" },
      { "<leader>t", group = "Terminal" },
      { "<leader>q", group = "Quit" },
      { "<leader>c", group = "Code" },
    })
  '';
}
