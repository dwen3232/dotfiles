-- Setting leader to <space>
vim.g.mapleader = " "

-- TODO: add window management keybindings?
-- TODO: add tab switching keybindings?

-- Let's center after moving a half page
vim.api.nvim_set_keymap("n", "<C-D>", "<C-D>zz", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-U>", "<C-U>zz", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Esc>", "<cmd>:noh<cr>", { noremap = true, silent = true })
