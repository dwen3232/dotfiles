return {
  "rcarriga/nvim-dap-ui",
  dependencies = { "mfussenegger/nvim-dap" },
  config = function()
    local dap = require("dap")
    local dap_ui = require("dapui")

    dap_ui.setup()

    dap.listeners.after.event_initialized["dapui_config"] = function()
      dap_ui.open()
    end

    dap.listeners.after.event_terminated["dapui_config"] = function()
      dap_ui.close()
    end

    dap.listeners.after.event_exited["dapui_config"] = function()
      dap_ui.close()
    end
  end,
}
