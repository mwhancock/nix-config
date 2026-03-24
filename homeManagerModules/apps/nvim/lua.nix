# -----------------------------------------------------------------------------
# MODULE: NEOVIM CUSTOM LUA CONFIGURATION
# Description: Dashboard, Auto-commands, and School Assignment Logic.
# -----------------------------------------------------------------------------
{...}: {
  # 1. LATEX METADATA (Required for the Assignment Export)
  home.file."/home/mark/Nextcloud/Documents/School/metadata.yaml".text = ''
    \usepackage{fontspec}
    \setmainfont{Inter}
    \usepackage{titling}

    \pretitle{\begin{center}\LARGE\bfseries}
    \posttitle{\end{center}\vskip 1.5em}
    \preauthor{\begin{center}\large Mark Hancock \par \vskip 1.5em Student \# 20140473 \end{center}}
    \postauthor{\vskip 1.5em}
    \predate{\begin{center}\large}
    \postdate{\end{center}\vfill\newpage}
  '';

  # 2. NVF LUA CONFIGURATION
  programs.nvf.settings.vim.luaConfigRC.myConfig = ''
    -------------------------------------------------------------------------------
    -- 1. BASIC BEHAVIOR & APPEARANCE
    -------------------------------------------------------------------------------
    vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

    vim.opt.conceallevel = 2
    vim.opt.concealcursor = "nc"

    -- Markdown Heading Colors
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
        [[                                __                ]],
        [[  ___     __    __   __   __   /\_\    ___ ___    ]],
        [[ /' _ `\ /'__`\/\ \ /\ \ /\ \ \/\ \  /' __` __`\  ]],
        [[ /\ \/\ \/\  __/\ \ \\ \ \ \ \ \ \ \ /\ \/\ \/\ \ ]],
        [[ \ \_\ \_\ \____\\ \____/ \ \_\ \ \_\\ \_\ \_\ \_\]],
        [[  \/_/\/_/\/____/ \/___/    \/_/  \/_/ \/_/\/_/\/_/]],
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

    -------------------------------------------------------------------------------
    -- 3. FILE EXPLORER (NEO-TREE)
    -------------------------------------------------------------------------------
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

    -------------------------------------------------------------------------------
    -- 4. ASSIGNMENT EXPORT LOGIC (PANDOC + TECTONIC)
    -------------------------------------------------------------------------------
    local function export_assignment_pdf()
      if vim.bo.filetype ~= "markdown" then return end

      local file = vim.fn.expand('%')
      local pdf = vim.fn.expand('%:r') .. '.pdf'
      local yaml_path = os.getenv("HOME") .. "/Nextcloud/Documents/School/metadata.yaml"
      local clean_title = vim.fn.expand('%:t:r'):gsub("_", " ")
      local current_date = os.date("%B %d, %Y")

      local cmd = {
        "pandoc", file,
        "-H", yaml_path,
        "-V", "geometry:margin=1in",
        "-V", "fontsize=11pt",
        "-o", pdf,
        "--pdf-engine=tectonic",
        "-M", "title=" .. clean_title,
        "-M", "date=" .. current_date,
      }

      vim.notify("Exporting PDF...", vim.log.levels.INFO)

      vim.fn.jobstart(cmd, {
        on_exit = function(_, code)
          if code == 0 then
            vim.notify("PDF Exported Successfully!", vim.log.levels.INFO)
          else
            vim.notify("PDF Export Failed!", vim.log.levels.ERROR)
          end
        end,
      })
    end

    -- Automatic export on save if PDF already exists
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*.md",
      callback = function()
        local pdf_file = vim.fn.expand('%:r') .. '.pdf'
        if vim.fn.filereadable(pdf_file) == 1 then
          export_assignment_pdf()
        end
      end,
    })

    -------------------------------------------------------------------------------
    -- 5. KEYMAPS & MENU LABELS (WHICH-KEY)
    -------------------------------------------------------------------------------
    local wk = require("which-key")
    wk.add({
      { "<leader>a", group = "Avante" },
      { "<leader>b", group = "Buffers" },
      { "<leader>c", group = "Code" },
      { "<leader>d", group = "Debug" },
      { "<leader>e", group = "Explorer" },
      { "<leader>g", group = "Git" },
      { "<leader>h", group = "Harpoon" },
      { "<leader>l", group = "LSP" },
      { "<leader>m", group = "Minimap" },
      { "<leader>n", group = "Notes" },
      { "<leader>ne", group = "Export" },
      { "<leader>nep", desc = "Export as PDF" },
      { "<leader>no", desc = "Open PDF Viewer" },
      { "<leader>na", desc = "Insert Template" },
      { "<leader>o", group = "Open" },
      { "<leader>q", group = "Quit" },
      { "<leader>r", group = "Rename" },
      { "<leader>s", group = "Flash" },
      { "<leader>t", group = "Terminal" },
    })

    -- PDF Export
    vim.keymap.set('n', '<leader>nep', export_assignment_pdf)

    -- Open PDF in Zathura
    vim.keymap.set('n', '<leader>no', function()
      local pdf = vim.fn.expand('%:r') .. '.pdf'
      if vim.fn.filereadable(pdf) == 1 then
        vim.notify("Opening Zathura...")
        vim.fn.jobstart({"zathura", pdf}, {detach = true})
      else
        vim.notify("No PDF found. Run <leader>nep first.", vim.log.levels.WARN)
      end
    end)

    -- Markdown Template
    local function insert_template()
      local lines = { "# ", "" }
      vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
      vim.api.nvim_win_set_cursor(0, {1, 2})
    end

    vim.keymap.set('n', '<leader>na', insert_template)
  '';
}
