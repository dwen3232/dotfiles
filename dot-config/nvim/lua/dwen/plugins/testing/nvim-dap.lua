-- TODO: set this up
return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "mfussenegger/nvim-dap-python",
  },
  config = function()
    -- DAP Python
    local python_dap = require("dap-python")
    local debugpy_path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
    python_dap.setup(debugpy_path)

    -- Signs
    vim.fn.sign_define("DapStopped", { text = "👉" })
    vim.fn.sign_define("DapBreakpoint", { text = "🔴" })
    vim.fn.sign_define("DapBreakpointCondition", { text = "🟡" })
    vim.fn.sign_define("DapBreakpointRejected", { text = "❌" })
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
