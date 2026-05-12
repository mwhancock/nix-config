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

    vim.opt.clipboard = "unnamedplus"
    vim.opt.conceallevel = 2
    vim.opt.concealcursor = "nc"
    vim.opt.tabstop = 4
    vim.opt.softtabstop = 4
    vim.opt.shiftwidth = 4
    vim.opt.expandtab = true
    vim.opt.number = true

    -- Markdown Heading Colors
    vim.api.nvim_set_hl(0, "@text.title.1.markdown", { fg = "#fb4934", bold = true })
    vim.api.nvim_set_hl(0, "@text.title.2.markdown", { fg = "#fabd2f", bold = true })
    vim.api.nvim_set_hl(0, "@text.title.3.markdown", { fg = "#b8bb26", bold = true })

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

    -- Auto-format settings for School Assignments
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function()
        vim.opt_local.textwidth = 72
        vim.opt_local.formatoptions = "tcqnj"
        vim.opt_local.autoindent = true
        vim.keymap.set("n", "p", "p`[v`]gq", { buffer = true, silent = true, desc = "Paste and auto-format" })
      end,
    })

    -------------------------------------------------------------------------------
    -- 2. UI & DASHBOARD (ALPHA-NVIM)
    -------------------------------------------------------------------------------
    local status_ok, alpha = pcall(require, "alpha")
    if status_ok then
      local dashboard = require("alpha.themes.dashboard")
      dashboard.section.header.val = {
        [[                                 __                ]],
        [[ ___     __    __   __   __   /\_\   ___ ___    ]],
        [[ /' _ `\ /'__`\/\ \ /\ \ /\ \ \/\ \  /' __` __`\  ]],
        [[ /\ \/\ \/\  __/\ \ \\ \ \ \ \ \ \ \ /\ \/\ \/\ \ ]],
        [[ \ \_\ \_\ \____\\ \____/ \ \_\ \ \_\\ \_\ \_\ \_\]],
        [[  \/_/\/_/\/____/ \/___/    \/_/  \/_/ \/_/\/_/\/_/]],
        [[                                                   ]],
        [[               -- THE GROOVY EDITOR --             ]],
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
        "--pdf-engine=xelatex",
        "--standalone",
        "-M", "title=" .. clean_title,
        "-M", "date=" .. current_date,
      }

      local stderr_data = {}
      vim.notify("Exporting PDF...", vim.log.levels.INFO)
      vim.fn.jobstart(cmd, {
        on_stderr = function(_, data)
          if data then
            for _, line in ipairs(data) do
              if line ~= "" then table.insert(stderr_data, line) end
            end
          end
        end,
        on_exit = function(_, code)
          if code == 0 then
            vim.notify("PDF Exported Successfully!", vim.log.levels.INFO)
          else
            local full_error = table.concat(stderr_data, "\n")
            vim.notify("Export Failed!", vim.log.levels.ERROR)
            print(full_error)
          end
        end,
      })
    end

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
    -- 5. KEYMAPS & WHICH-KEY
    -------------------------------------------------------------------------------
    local wk = require("which-key")
    wk.add({
      { "<leader>n", group = "Notes" },
      { "<leader>ne", group = "Export" },
      { "<leader>nt", desc = "Toggle Checkbox" },
    })

    -- Checkbox Toggle Logic
    vim.keymap.set("n", "<leader>nt", function()
        local line = vim.api.nvim_get_current_line()
        local nl = line
        if line:match("%%- %%[x%%]") then
            nl = line:gsub("%%- %%[x%%]", "- [ ]")
        elseif line:match("%%- %%[ %%]") then
            nl = line:gsub("%%- %%[ %%]", "- [x]")
        elseif line:match("^%%s*%%- ") then
            nl = line:gsub("%%- ", "- [ ] ", 1)
        end
        if nl ~= line then
            vim.api.nvim_set_current_line(nl)
        end
    end, { desc = "Toggle Markdown Checkbox" })

    -- Corrected Visual Bold (using <leader>sb to save your 'b' key)
    vim.keymap.set("v", "<leader>sb", [[c**<C-r>"**<Esc>]], { desc = "Bold selection", silent = true })

    vim.keymap.set('n', '<leader>nep', export_assignment_pdf, { desc = "Export PDF" })
    
    vim.keymap.set('n', '<leader>no', function()
      local pdf = vim.fn.expand('%:r') .. '.pdf'
      if vim.fn.filereadable(pdf) == 1 then
        vim.fn.jobstart({"zathura", pdf}, {detach = true})
      else
        vim.notify("No PDF found.", vim.log.levels.WARN)
      end
    end, { desc = "Open PDF" })

    vim.keymap.set('n', '<leader>na', function()
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "# ", "" })
      vim.api.nvim_win_set_cursor(0, {1, 2})
    end, { desc = "Insert Template" })

    -------------------------------------------------------------------------------
    -- 6. DYNAMIC AUTO-WRAPPING
    -------------------------------------------------------------------------------
    local wrap_group = vim.api.nvim_create_augroup("DynamicWrap", { clear = true })
    vim.api.nvim_create_autocmd({ "WinResized", "VimResized", "BufWinEnter", "WinEnter" }, {
        group = wrap_group,
        callback = function()
            local threshold = 110
            local win_width = vim.api.nvim_win_get_width(0)
            local ft = vim.bo.filetype
            local excluded_ft = { "NvimTree", "neo-tree", "dashboard", "alpha" }

            if not vim.tbl_contains(excluded_ft, ft) then
                if win_width < threshold then
                    vim.opt_local.wrap = true
                    vim.opt_local.linebreak = true
                    vim.opt_local.breakindent = true
                    vim.opt_local.showbreak = "↳ "
                else
                    vim.opt_local.wrap = false
                end
            end
        end,
    })
  '';
}
