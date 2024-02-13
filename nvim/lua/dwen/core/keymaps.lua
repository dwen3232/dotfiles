-- Setting leader to <space>
vim.g.mapleader = " "

-- TODO: add tab switching keybindings?

-- Let's center after moving a half page
vim.api.nvim_set_keymap("n", "<C-D>", "<C-D>zz", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-U>", "<C-U>zz", { noremap = true, silent = true })
-- Let's make them closer to k and j
vim.api.nvim_set_keymap("n", "<C-J>", "<C-D>zz", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-K>", "<C-U>zz", { noremap = true, silent = true })
