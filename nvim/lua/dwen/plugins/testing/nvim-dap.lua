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


    -- Mappings
    local keymap = vim.keymap -- for conciseness
    local opts = { noremap = true, silent = true }

    opts.desc = "Toggle breakpoint"
    keymap.set("n", "<leader>db", "<cmd>DapToggleBreakpoint<CR>", opts)
  end,
}
