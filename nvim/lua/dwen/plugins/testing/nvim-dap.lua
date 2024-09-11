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

    vim.fn.sign_define("DapStopped", { text = "👉" })
    vim.fn.sign_define("DapBreakpoint", { text = "🔴" })
    vim.fn.sign_define("DapBreakpointCondition", { text = "🟡" })
    vim.fn.sign_define("DapBreakpointRejected", { text = "❌" })

    -- Mappings
    local keymap = vim.keymap -- for conciseness
    local opts = { noremap = true, silent = true }

    -- TODO: this could be refactored to use the lua API directly
    -- should do that in the future, because the lua API is much more powerful
    opts.desc = "Toggle breakpoint"
    keymap.set("n", "<leader>db", "<cmd>DapToggleBreakpoint<CR>", opts)

    opts.desc = "Toggle REPL shell"
    keymap.set("n", "<leader>ds", "<cmd>DapToggleRepl<CR>", opts)

    opts.desc = "Step into function"
    keymap.set("n", "<leader>di", "<cmd>DapStepInto<CR>", opts)

    opts.desc = "Step out of function"
    keymap.set("n", "<leader>do", "<cmd>DapStepOut<CR>", opts)

    opts.desc = "Step over line"
    keymap.set("n", "<leader>dn", "<cmd>DapStepOver<CR>", opts)

    opts.desc = "Continue to next breakpoint"
    keymap.set("n", "<leader>dc", "<cmd>DapContinue<CR>", opts)

    opts.desc = "Disconnect"
    keymap.set("n", "<leader>dd", "<cmd>DapDisconnect<CR>", opts)
  end,
}
