{...}: {
  programs.nvf.settings.vim.luaConfigRC.myConfig = ''
        -------------------------------------------------------------------------------
        -- 1. BASIC BEHAVIOR
        -------------------------------------------------------------------------------
        vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

        vim.opt.conceallevel = 2
        vim.opt.concealcursor = "nc"
        vim.api.nvim_set_hl(0, "@text.title.1.markdown", { fg = "#fb4934", bold = true }) -- Red
        vim.api.nvim_set_hl(0, "@text.title.2.markdown", { fg = "#fabd2f", bold = true }) -- Yellow
        vim.api.nvim_set_hl(0, "@text.title.3.markdown", { fg = "#b8bb26", bold = true }) -- Green

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
          { "<leader>o", group = "Open" },
          { "<leader>c", group = "Code" },
          { "<leader>ne", group = "Export" },
          { "<leader>n", group = "Notes" },
        })

        -- -------------------------------------------------------------------------
    -- 4. PDF Export Keybind
    -- -------------------------------------------------------------------------

    vim.keymap.set('n', '<leader>nep', function()
      local file = vim.fn.expand('%')
      local pdf = vim.fn.expand('%:r') .. '.pdf'

      local cmd = string.format("pandoc %s -o %s --pdf-engine=tectonic", file, pdf)

      print("Exporting to PDF...")
      vim.fn.jobstart(cmd, {
        on_exit = function(_, code)
          if code == 0 then
            print("PDF Exported: " .. pdf)
          else
            print("PDF Export Failed!")
          end
        end
      })
    end, { desc = "Export Markdown to PDF" })


     -- -------------------------------------------------------------------------
     -- Markdown Template Menu
     -- -------------------------------------------------------------------------
    local function insert_template(type)
        local date = os.date("%B %d, %Y")
        local lines = {}

        if type == "assignment" then
            lines = {
                "---",
                'title: "' .. vim.fn.expand("%:t:r") .. '"',
                'author: "Mark Hancock"',
                'student number: "20140473"',
                'date: "' .. date .. '"',
                "geometry: margin=1in",
                "fontsize: 11pt",
                "---",
                "",
                "",
            }
        elseif type == "lab" then
            lines = {
                "---",
                'title: "' .. vim.fn.expand("%:t:r") .. '"',
                'author: "Mark Hancock"',
                'student number: "20140473"',
                'date: "' .. date .. '"',
                "---",
                "",
                "    ",
                "```",
            }
        elseif type == "coop" then
            lines = {
                "# Project Update: " .. date,
                "## Current Tasks",
                "- [ ] ",
                "",
                "## Notes on Biometric Sensors",
                "",
            }
        end

        vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    end

    -- Register the Keymaps
    vim.keymap.set('n', '<leader>na', function() insert_template("assignment") end, { desc = "Template: Assignment" })
    vim.keymap.set('n', '<leader>nl', function() insert_template("lab") end, { desc = "Template: Lab Report" })
    vim.keymap.set('n', '<leader>nc', function() insert_template("coop") end, { desc = "Template: Co-op Log" })
  '';
}
