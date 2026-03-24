# -----------------------------------------------------------------------------
# MODULE: NEOVIM DEBUGGER (DAP)
# Description: Configuration for lldb (C/C++) and Java debugging.
# -----------------------------------------------------------------------------
{ pkgs, ... }:
{
  programs.nvf.settings.vim = {
    # 1. SYSTEM DEPENDENCIES
    extraPackages = with pkgs; [ 
      lldb          # For C/C++ debugging
      jdk           # For Java labs
      netcoredbg    # (Optional) if you do any C#
    ];

    # 2. NVF DAP SETTINGS
    debugger.nvim-dap = {
      enable = true;
      ui.enable = true; # Enables dap-ui automatically
    };

    # 3. EXTRA PLUGINS (Virtual Text)
    extraPlugins = with pkgs.vimPlugins; {
      dap-virtual-text = {
        package = nvim-dap-virtual-text;
        setup = "require('nvim-dap-virtual-text').setup({})";
      };
    };

    # 4. LUA CONFIGURATION (Adapters & Listeners)
    pluginRC.dap-config = ''
      local dap = require("dap")
      local dapui = require("dapui")

      -- LLDB Adapter for C/C++
      dap.adapters.lldb = {
        type = "executable",
        command = "${pkgs.lldb}/bin/lldb-dap",
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
          args = {},
        },
      }
      dap.configurations.cpp = dap.configurations.c

      -- Auto-open/close UI
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
    '';
  };
}
