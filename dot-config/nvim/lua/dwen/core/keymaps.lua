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

-- Putting this here since file types with no LSP may stil have diagnostics (due to linters)
vim.keymap.set(
  "n",
  "<leader>xx",
  vim.diagnostic.open_float,
  { noremap = true, silent = true, desc = "Show line diagnostics" }
) -- show diagnostics for line

-- Toggle between relative and absolute line numbers
vim.keymap.set("n", "<leader>on", function()
  vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, { noremap = true, silent = true, desc = "Toggle relative line numbers" })

-- Override Ctrl+g to show file info AND copy relative path to clipboard
vim.keymap.set("n", "<C-g>", function()
  local filepath = vim.fn.expand('%')
  vim.fn.setreg('+', filepath)
  vim.cmd('normal! 1\x07') -- Execute Ctrl+g (show file info)
end, { noremap = true, desc = "Show file info and copy path to clipboard" })
