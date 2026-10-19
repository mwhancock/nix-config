-- Inline mermaid rendering in markdown buffers via diagram.nvim.
--
-- Renders ```mermaid fences as PNG images floating over the code, powered by
-- image.nvim's kitty-graphics backend (Ghostty speaks the protocol). mmdc
-- (mermaid-cli, in modules/packages/default.nix) does the actual rendering;
-- its palette comes from ~/.config/omarchy/mermaid-mmdc.json, regenerated
-- from the active Omarchy theme by the theme-set hook
-- ~/.config/omarchy/hooks/theme-set.d/mermaid-mmdc. No `theme` is set here
-- so diagram.nvim does not pass `-t` and override that config.
--
-- opts is a function, not a table: the integrations require runs inside it,
-- and a table-valued opts is evaluated while lazy.nvim parses the spec --
-- before the plugin is installed on a first run -- which makes the whole
-- spec file error and the plugin never installs.

return {
  "3rd/diagram.nvim",
  dependencies = {
    -- The magick luarock is only used by image.nvim's :ImageInfo command;
    -- dimensions are parsed natively and the kitty backend needs no rock.
    -- lazy.nvim's rocks installer is disabled globally in config/lazy.lua.
    {
      "3rd/image.nvim",
      opts = {
        -- image.nvim's default squeezes any image past 50% of the window
        -- height, which halved mermaid's text on screen (an ER diagram's
        -- 13px glyphs were drawn at ~8px). Let diagrams use the full window;
        -- the 100% window caps still stop them overflowing it.
        max_height_window_percentage = 100,
      },
    },
  },
  ft = { "markdown" },
  opts = function()
    return {
      integrations = {
        require("diagram.integrations.markdown"),
      },
      renderer_options = {
        mermaid = {
          -- Transparent page so the diagram floats over the buffer background
          -- at any theme; the palette itself lives in the -c config below.
          background = "transparent",
          -- mmdc fit-shrinks wide diagrams onto its ~784px page, taking mermaid's
          -- 16px text down to ~13px before image.nvim even sees it. Rasterizing
          -- at 2x doubles the text pixels, so diagrams land at roughly terminal
          -- font size instead of a smudge. Raise/lower to taste; clear
          -- ~/.cache/nvim/diagram-cache/mermaid afterwards -- the cache keys on
          -- diagram source only, not on these flags.
          scale = 2,
          cli_args = {
            -- -c (lowercase) is mermaid's theme config; -C is --cssFile.
            -- No --no-sandbox: nixpkgs' mermaid-cli wrapper already points
            -- Puppeteer at its own Chromium, which runs sandboxless on NixOS.
            "-c",
            vim.fn.expand("~/.config/omarchy/mermaid-mmdc.json"),
          },
        },
      },
    }
  end,
  keys = {
    {
      "<leader>mh",
      function()
        require("diagram").show_diagram_hover()
      end,
      mode = "n",
      ft = { "markdown" },
      desc = "Show diagram in new tab",
    },
  },
  config = function(_, opts)
    require("diagram").setup(opts)

    -- The first render runs mid-startup: lazy loads this plugin on FileType,
    -- before the UI is up, and nvim's initial screen clear wipes the
    -- kitty-protocol image placement right after it is drawn. Re-render once
    -- after startup (the PNG is cached, so this is instant); every later
    -- render is driven by diagram.nvim's own InsertLeave/BufWinEnter/TextChanged
    -- autocmds, which fire once the UI is live.
    vim.api.nvim_create_autocmd("VimEnter", {
      group = vim.api.nvim_create_augroup("DiagramPostStartupRender", { clear = true }),
      callback = function()
        vim.defer_fn(function()
          local buf = vim.api.nvim_get_current_buf()
          if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "markdown" then
            require("diagram").render()
          end
        end, 150)
      end,
    })
  end,
}
