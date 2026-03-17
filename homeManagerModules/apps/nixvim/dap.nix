{ pkgs, ... }:
{
  programs.nixvim = {
    extraPackages = with pkgs; [
      lldb # C debugger
      jdk # Java (already have this)
    ];

    plugins = {
      # Core DAP plugin
      dap = {
        enable = true;
        configurations = {
          c = [
            {
              name = "Launch";
              type = "lldb";
              request = "launch";
              program.__raw = ''
                function()
                  return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                end
              '';
              cwd = "\${workspaceFolder}";
              stopOnEntry = false;
              args = [ ];
            }
          ];
          java = [
            {
              name = "Launch Java";
              type = "java";
              request = "launch";
              mainClass = "";
            }
          ];
        };
        adapters = {
          executables = {
            lldb = {
              command = "lldb-dap";
            };
          };
        };
      };

      # UI for DAP
      dap-ui = {
        enable = true;
        settings = {
          icons = {
            expanded = "▾";
            collapsed = "▸";
            current_frame = "▸";
          };
          layouts = [
            {
              elements = [
                { id = "scopes"; size = 0.25; }
                { id = "breakpoints"; size = 0.25; }
                { id = "stacks"; size = 0.25; }
                { id = "watches"; size = 0.25; }
              ];
              position = "left";
              size = 40;
            }
            {
              elements = [
                { id = "repl"; size = 0.5; }
                { id = "console"; size = 0.5; }
              ];
              position = "bottom";
              size = 10;
            }
          ];
        };
      };

      # Virtual text showing variable values inline
      dap-virtual-text.enable = true;
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>db";
        action.__raw = ''function() require("dap").toggle_breakpoint() end'';
        options.desc = "Toggle Breakpoint";
      }
      {
        mode = "n";
        key = "<leader>dc";
        action.__raw = ''function() require("dap").continue() end'';
        options.desc = "Continue";
      }
      {
        mode = "n";
        key = "<leader>di";
        action.__raw = ''function() require("dap").step_into() end'';
        options.desc = "Step Into";
      }
      {
        mode = "n";
        key = "<leader>do";
        action.__raw = ''function() require("dap").step_over() end'';
        options.desc = "Step Over";
      }
      {
        mode = "n";
        key = "<leader>dO";
        action.__raw = ''function() require("dap").step_out() end'';
        options.desc = "Step Out";
      }
      {
        mode = "n";
        key = "<leader>du";
        action.__raw = ''function() require("dapui").toggle() end'';
        options.desc = "Toggle DAP UI";
      }
      {
        mode = "n";
        key = "<leader>dr";
        action.__raw = ''function() require("dap").repl.open() end'';
        options.desc = "Open REPL";
      }
    ];

    extraConfigLua = ''
      -- Auto open/close dapui
      local dap, dapui = require("dap"), require("dapui")
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
