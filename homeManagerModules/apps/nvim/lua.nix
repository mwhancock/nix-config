{ ... }:
{
  programs.nvf.settings.vim.luaConfigRC.myConfig = ''
    -------------------------------------------------------------------------------
    -- 1. BASIC BEHAVIOR & UTILS
    -------------------------------------------------------------------------------
    -- Prevent space from moving cursor (it's our leader key)
    vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

    -- Terminal auto-insert mode
    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "*",
      callback = function()
        vim.cmd("startinsert")
      end,
    })

    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "term://*",
      callback = function()
        vim.cmd("startinsert")
      end,
    })

    -- Autosave on focus change
    vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
      callback = function()
        if vim.bo.modified and not vim.bo.readonly and vim.fn.expand("%") ~= "" then
          vim.cmd("silent! write")
        end
      end,
    })

    -------------------------------------------------------------------------------
    -- 2. UI & COSMETICS
    -------------------------------------------------------------------------------
    -- Cursor: block in normal, bar in insert
    vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor"

    -- Dynamic colorcolumn (adjusts based on window size)
    vim.api.nvim_create_autocmd({"VimResized", "VimEnter"}, {
      callback = function()
        local cols = vim.o.columns
        local percent = cols < 100 and 0.80 or cols < 160 and 0.75 or 0.66
        vim.opt.colorcolumn = tostring(math.floor(cols * percent))
      end,
    })

    -- Neo-tree Gruvbox Git Colors
    local function set_neotree_colors()
      vim.api.nvim_set_hl(0, "NeoTreeGitModified",  { fg = "#fabd2f" })
      vim.api.nvim_set_hl(0, "NeoTreeGitUntracked", { fg = "#b8bb26" })
      vim.api.nvim_set_hl(0, "NeoTreeGitStaged",    { fg = "#83a598" })
      vim.api.nvim_set_hl(0, "NeoTreeGitDeleted",   { fg = "#fb4934" })
      vim.api.nvim_set_hl(0, "NeoTreeGitRenamed",   { fg = "#fe8019" })
      vim.api.nvim_set_hl(0, "NeoTreeGitIgnored",   { fg = "#928374" })
      vim.api.nvim_set_hl(0, "NeoTreeGitConflict",  { fg = "#fb4934" })
    end

    vim.api.nvim_create_autocmd("ColorScheme", { callback = set_neotree_colors })
    set_neotree_colors() -- Apply immediately

    -------------------------------------------------------------------------------
    -- 3. RAINBOW INDENT GUIDES (IBL)
    -------------------------------------------------------------------------------
    local hooks = require("ibl.hooks")
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      vim.api.nvim_set_hl(0, "IndentBlanklineRed",    { fg = "#cc241d" })
      vim.api.nvim_set_hl(0, "IndentBlanklineOrange", { fg = "#d65d0e" })
      vim.api.nvim_set_hl(0, "IndentBlanklineYellow", { fg = "#d79921" })
      vim.api.nvim_set_hl(0, "IndentBlanklineGreen",  { fg = "#689d6a" })
      vim.api.nvim_set_hl(0, "IndentBlanklineBlue",   { fg = "#458588" })
      vim.api.nvim_set_hl(0, "IndentBlanklinePurple", { fg = "#b16286" })
      vim.api.nvim_set_hl(0, "IndentBlanklineCurrent",{ fg = "#fabd2f", bold = true })
    end)

    -------------------------------------------------------------------------------
    -- 4. GRUVBOX DASHBOARD (ALPHA-NVIM)
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
      dashboard.section.header.opts.hl = "Keyword" -- Makes it Gruvbox Orange/Red

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
    -- 5. PLUGINS & FILETYPES
    -------------------------------------------------------------------------------
    -- Neo-tree on startup (only if no file is specified)
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        if vim.fn.argc() == 0 then
          vim.defer_fn(function()
            require("neo-tree.command").execute({ action = "show" })
          end, 100)
        end
      end,
    })

    -- Dynamic Neo-tree width
    vim.api.nvim_create_autocmd("VimResized", {
      callback = function()
        local cols = vim.o.columns
        local width = cols < 100 and 20 or cols < 160 and 25 or 30
        require("neo-tree.command").execute({
          action = "show",
          position = "left",
          width = width,
        })
      end,
    })

    -- Custom Keymap: Open PDF in Zathura
    vim.keymap.set("n", "<leader>op", function()
      local pdf = vim.fn.glob(vim.fn.getcwd() .. "/*.pdf")
      if pdf ~= "" then
        vim.fn.jobstart({"zathura", pdf})
      end
    end, { desc = "Open PDF" })
  '';
}
