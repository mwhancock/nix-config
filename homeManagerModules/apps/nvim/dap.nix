# -----------------------------------------------------------------------------
# MODULE: NEOVIM DEBUGGER (DAP)
# Description: Configuration for lldb (C/C++) and Java debugging.
# -----------------------------------------------------------------------------
{pkgs, ...}: {
  programs.nvf.settings.vim = {
    extraPackages = with pkgs; [lldb];

    debugger.nvim-dap = {
      enable = true;
      ui.enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; {
      dap-virtual-text = {
        package = nvim-dap-virtual-text;
        setup = "require('nvim-dap-virtual-text').setup({})";
      };
    };

    pluginRC.dap-config = ''
      -- Lua block inside Nix string
      local dap = require("dap")
      local dapui = require("dapui")

      dap.adapters.lldb = {
        type = "executable",
        command = "lldb-dap",
        name = "lldb",
      }

      dap.configurations.c = {
        {
          name = "Launch",
          type = "lldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "''${workspaceFolder}",
          stopOnEntry = false,
        },
      }
      dap.configurations.cpp = dap.configurations.c

      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
    '';
  };
}
