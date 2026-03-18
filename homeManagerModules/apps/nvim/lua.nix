{ ... }:
{
  programs.nvf.settings.vim.luaConfigRC.myConfig = ''
          -- Prevent space from moving cursor
          vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

          -- Dynamic colorcolumn
          vim.api.nvim_create_autocmd({"VimResized", "VimEnter"}, {
            callback = function()
              local cols = vim.o.columns
              local percent
              if cols < 100 then
                percent = 0.80
              elseif cols < 160 then
                percent = 0.75
              else
                percent = 0.66
              end
              vim.opt.colorcolumn = tostring(math.floor(cols * percent))
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

    -- Neo-tree gruvbox colors
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        -- Modified files - gruvbox yellow
        vim.api.nvim_set_hl(0, "NeoTreeGitModified", { fg = "#fabd2f" })
        -- Untracked files - gruvbox green
        vim.api.nvim_set_hl(0, "NeoTreeGitUntracked", { fg = "#b8bb26" })
        -- Staged files - gruvbox blue
        vim.api.nvim_set_hl(0, "NeoTreeGitStaged", { fg = "#83a598" })
        -- Deleted files - gruvbox red
        vim.api.nvim_set_hl(0, "NeoTreeGitDeleted", { fg = "#fb4934" })
        -- Renamed files - gruvbox orange
        vim.api.nvim_set_hl(0, "NeoTreeGitRenamed", { fg = "#fe8019" })
        -- Ignored files - gruvbox gray
        vim.api.nvim_set_hl(0, "NeoTreeGitIgnored", { fg = "#928374" })
        -- Conflicts - gruvbox red
        vim.api.nvim_set_hl(0, "NeoTreeGitConflict", { fg = "#fb4934" })
      end,
    })

    -- Apply immediately
    vim.api.nvim_set_hl(0, "NeoTreeGitModified", { fg = "#fabd2f" })
    vim.api.nvim_set_hl(0, "NeoTreeGitUntracked", { fg = "#b8bb26" })
    vim.api.nvim_set_hl(0, "NeoTreeGitStaged", { fg = "#83a598" })
    vim.api.nvim_set_hl(0, "NeoTreeGitDeleted", { fg = "#fb4934" })
    vim.api.nvim_set_hl(0, "NeoTreeGitRenamed", { fg = "#fe8019" })
    vim.api.nvim_set_hl(0, "NeoTreeGitIgnored", { fg = "#928374" })
    vim.api.nvim_set_hl(0, "NeoTreeGitConflict", { fg = "#fb4934" })

          -- Neo-tree on startup
          vim.api.nvim_create_autocmd("VimEnter", {
            callback = function()
              if vim.fn.argc() == 0 then
                vim.defer_fn(function()
                  require("neo-tree.command").execute({ action = "show" })
                end, 100)
              end
            end,
          })

          -- Minimap auto hide with terminal
          vim.api.nvim_create_autocmd("TermOpen", {
            callback = function()
              require("mini.map").close()
            end,
          })
          vim.api.nvim_create_autocmd({"TermClose", "BufWinLeave"}, {
            callback = function()
              if vim.bo.buftype == "terminal" then
                  vim.defer_fn(function()
                    require("mini.map").open()
                  end, 100)
                end
              end,
            })

          -- Dynamic neo-tree width
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

          -- Cursor block in normal, bar in insert
          vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor"
  
        -- Open PDF in zathura
        vim.keymap.set("n", "<leader>op", function()
        local pdf = vim.fn.glob (vim.fn.getcwd().. "/*.pdf")
          if pdf ~= "" then
          vim.fn.jobstart({"zathura", pdf})
            end
            end, { desc = "Open PDF" })
  '';
}
