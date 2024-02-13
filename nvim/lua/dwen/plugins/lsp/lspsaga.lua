-- https://nvimdev.github.io/lspsaga/
-- TODO: configure this shit
return {
  "nvimdev/lspsaga.nvim",
  event = { "LspAttach" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local lspsaga = require("lspsaga")

    lspsaga.setup({})

    local keymap = vim.keymap
    local opts = { noremap = true, silent = true }

    -- TODO: this doesn't work in nvim-tree for some reason
    opts.desc = "Toggle terminal"
    keymap.set("n", "<leader>tt", "<cmd>Lspsaga term_toggle<CR>", opts) -- show definition, references

    opts.desc = "Show LSP references"
    keymap.set("n", "gr", "<cmd>Lspsaga finder<CR>", opts) -- show definition, references

    opts.desc = "Peek definition"
    keymap.set("n", "K", "<cmd>Lspsaga peek_definition<CR>", opts) -- show documentation for what is under cursor

    opts.desc = "See available code actions"
    keymap.set({ "n", "v" }, "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts) -- see available code actions, in visual mode will apply to selection

    opts.desc = "Show buffer diagnostics"
    keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

    opts.desc = "Show line diagnostics"
    keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

    opts.desc = "Go to previous diagnostic"
    -- keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer
    keymap.set("n", "[d", "<cmd>Lspsaga diagonistic_jump_prev<CR>", opts) -- jump to previous diagnostic in buffer

    opts.desc = "Go to next diagnostic"
    keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer
  end,
}
