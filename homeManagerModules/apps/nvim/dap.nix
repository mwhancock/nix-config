{ pkgs, ... }:
{
  programs.nvf.settings.vim = {
    extraPackages = with pkgs; [
      lldb
    ];

    debugger = {
      nvim-dap = {
        enable = true;
        ui.enable = true;
      };
    };

    extraPlugins = with pkgs.vimPlugins; {
      dap-virtual-text = {
        package = nvim-dap-virtual-text;
        setup = ''
          require("nvim-dap-virtual-text").setup({})
        '';
      };
    };

    pluginRC.dap-config = ''
      local dap = require("dap")
      local dapui = require("dapui")

      -- C adapter
      dap.adapters.lldb = {
        type = "executable",
        command = "lldb-dap",
        name = "lldb",
      }

      -- C configuration
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

      -- Java uses jdtls built-in DAP
      dap.configurations.java = {
        {
          name = "Launch Java",
          type = "java",
          request = "launch",
          mainClass = "",
        },
      }

      -- Auto open/close dapui
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    '';
  };
}
