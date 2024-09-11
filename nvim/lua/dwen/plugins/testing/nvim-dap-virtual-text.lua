return {
  "theHamsta/nvim-dap-virtual-text",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "mfussenegger/nvim-dap",
  },
  config = function()
    require("nvim-dap-virtual-text").setup({})

    -- Mappings
    local keymap = vim.keymap -- for conciseness
    local opts = { noremap = true, silent = true }

    opts.desc = "Toggle virtual text"
    keymap.set("n", "<leader>dv", "<cmd>DapVirtualTextToggle<CR>", opts)

    opts.desc = "Refresh virtual text"
    keymap.set("n", "<leader>dr", "<cmd>DapVirtualTextForceRefresh<CR>", opts)
  end,
}
