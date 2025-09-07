-- TODO: set this up
return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "mfussenegger/nvim-dap-python",
    "banjo/package-pilot.nvim",
  },
  config = function()
    -- DAP Python
    local python_dap = require("dap-python")
    local debugpy_path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
    python_dap.setup(debugpy_path)

    -- DAP JS
    -- local js_dap = require("js-debug-adapter")
    -- js_dap.setup()

    -- Signs
    vim.fn.sign_define("DapStopped", { text = "👉" })
    vim.fn.sign_define("DapBreakpoint", { text = "🔴" })
    vim.fn.sign_define("DapBreakpointCondition", { text = "🟡" })
    vim.fn.sign_define("DapBreakpointRejected", { text = "❌" })

    -- TODO: Fix `could not resolve source map` issue when starting debugger for typescript
    local dap = require("dap")
    if not dap.adapters["pwa-node"] then
      require("dap").adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = {
            "/Users/davidwen/.local/share/nvim/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
            "${port}",
          },
        },
      }
    end
    if not dap.adapters["node"] then
      dap.adapters["node"] = function(cb, config)
        if config.type == "node" then
          config.type = "pwa-node"
        end
        local nativeAdapter = dap.adapters["pwa-node"]
        if type(nativeAdapter) == "function" then
          nativeAdapter(cb, config)
        else
          cb(nativeAdapter)
        end
      end
    end

    local js_filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" }

    local vscode = require("dap.ext.vscode")
    vscode.type_to_filetypes["node"] = js_filetypes
    vscode.type_to_filetypes["pwa-node"] = js_filetypes

    -- local function pick_script()
    --   local pilot = require("package-pilot")
    --
    --   -- Get the directory of the current buffer file
    --   local current_file = vim.api.nvim_buf_get_name(0)
    --   if current_file == "" then
    --     vim.notify("No file in current buffer", vim.log.levels.ERROR)
    --     return require("dap").ABORT
    --   end
    --
    --   local current_dir = vim.fs.dirname(current_file)
    --   local package = pilot.find_package_file({ dir = current_dir })
    --
    --   if not package then
    --     vim.notify("No package.json found", vim.log.levels.ERROR)
    --     return require("dap").ABORT
    --   end
    --
    --   local scripts = pilot.get_all_scripts(package)
    --
    --   local label_fn = function(script)
    --     return script
    --   end
    --
    --   local co, ismain = coroutine.running()
    --   local ui = require("dap.ui")
    --   local pick = (co and not ismain) and ui.pick_one or ui.pick_one_sync
    --   local result = pick(scripts, "Select script", label_fn)
    --   return result or require("dap").ABORT
    -- end
    local function pick_script()
      local pilot = require("package-pilot")

      local current_dir = vim.fn.getcwd()
      local package = pilot.find_package_file({ dir = current_dir })

      if not package then
        vim.notify("No package.json found", vim.log.levels.ERROR)
        return require("dap").ABORT
      end

      local scripts = pilot.get_all_scripts(package)

      local label_fn = function(script)
        return script
      end

      local co, ismain = coroutine.running()
      local ui = require("dap.ui")
      local pick = (co and not ismain) and ui.pick_one or ui.pick_one_sync
      local result = pick(scripts, "Select script", label_fn)
      return result or require("dap").ABORT
    end

    for _, language in ipairs(js_filetypes) do
      if not dap.configurations[language] then
        dap.configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
            resolveSourceMapLocations = {
              "${workspaceFolder}/packages/**",
              "!**/node_modules/**",
            },
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
            resolveSourceMapLocations = {
              "${workspaceFolder}/packages/**",
              "!**/node_modules/**",
            },
          },
          {
            type = "node",
            request = "launch",
            name = "Pick script (pnpm)",
            runtimeExecutable = "pnpm",
            runtimeArgs = { "run", pick_script },
            cwd = "${workspaceFolder}",
            resolveSourceMapLocations = {
              "${workspaceFolder}/**",
              "!**/node_modules/**",
            },
          },
        }
      end
    end
  end,
  keys = {
    {
      "<leader>db",
      "<cmd>DapToggleBreakpoint<CR>",
      desc = "Toggle breakpoint",
    },
    {
      "<leader>ds",
      "<cmd>DapToggleRepl<CR>",
      desc = "Toggle REPL shell",
    },
    {
      "<leader>di",
      "<cmd>DapStepInto<CR>",
      desc = "Step into function",
    },
    {
      "<leader>do",
      "<cmd>DapStepOut<CR>",
      desc = "Step out of function",
    },
    {
      "<leader>dn",
      "<cmd>DapStepOver<CR>",
      desc = "Step over line",
    },
    {
      "<leader>dc",
      "<cmd>DapContinue<CR>",
      desc = "Continue to next breakpoint",
    },
    {
      "<leader>dd",
      "<cmd>DapDisconnect<CR>",
      desc = "Disconnect",
    },
  },
}
