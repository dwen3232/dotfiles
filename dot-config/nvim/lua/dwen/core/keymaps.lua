-- Setting leader to <space>
vim.g.mapleader = " "

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- TODO: add window management keybindings?
-- TODO: add tab switching keybindings?

-- Let's center after moving a half page
vim.api.nvim_set_keymap("n", "<C-D>", "<C-D>zz", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-U>", "<C-U>zz", { noremap = true, silent = true })

-- Removes highlights when hitting ESC
vim.api.nvim_set_keymap("n", "<Esc>", "<cmd>:noh<cr>", { noremap = true, silent = true })

-- Putting this here since file types with no LSP may stil have diagnostics (due to linters)
vim.keymap.set(
  "n",
  "<leader>xx",
  vim.diagnostic.open_float,
  { noremap = true, silent = true, desc = "Show line diagnostics" }
) -- show diagnostics for line
