return {
  -- Treesitter parsers
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "c",
        "cpp",
        "rust",
        "ron",
        "java",
        "kotlin",
        "python",
        "ninja",
        "rst",
        "markdown",
        "markdown_inline",
        "mermaid",
        "bash",
        "lua",
        "toml",
        "json",
        "yaml",
        "latex",
        "cmake",
        "make",
      })
    end,
  },

  -- Language servers LazyVim has no extra for, plus the Nix one this machine
  -- prefers.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Shell scripts. LazyVim ships no lang.bash extra, so bashls is the one
        -- server that has to be named here or it never starts.
        bashls = {},
        -- nixd instead of the nil_ls the nix extra wires up: nixd understands
        -- flakes and can complete NixOS options, which is most of what editing
        -- /etc/nixos is about. It is installed system-wide by
        -- modules/packages/default.nix, so mason is told not to fetch a second
        -- copy.
        nixd = { mason = false },
        nil_ls = { enabled = false },
        -- marksman from nixpkgs, not from mason. Mason's build is a
        -- self-contained .NET binary that aborts on NixOS because it cannot
        -- find libicu:
        --
        --   Process terminated. Couldn't find a valid ICU package installed
        --   on the system.
        --
        -- The nixpkgs one is built against the system ICU, so it actually
        -- starts. It is installed by hosts/nixos/home.nix.
        marksman = { mason = false },
      },
    },
  },

  -- Mason ensure installed tools
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "codelldb",
        "jdtls",
        "clangd",
        "marksman",
        "java-debug-adapter",
        "java-test",
        "kotlin-language-server",
        "ktlint",
        "kotlin-debug-adapter",
        "pyright",
        "ruff",
        "debugpy",
      })
    end,
  },

  -- Disable markdown style linting for markdown documents (no line-length, blank-line, or HTML errors)
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = {},
        ["markdown.mdx"] = {},
      },
    },
  },

  -- Clean formatters for markdown
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        markdown = { "prettier" },
        ["markdown.mdx"] = { "prettier" },
      },
    },
  },
}
