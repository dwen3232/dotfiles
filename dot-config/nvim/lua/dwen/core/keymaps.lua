-- Setting leader to <space>
vim.g.mapleader = " "

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- TODO: add window management keybindings?
-- TODO: add tab switching keybindings?

-- Let's center after moving a half page
-- vim.api.nvim_set_keymap("n", "<C-D>", "<C-D>zz", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", "<C-U>", "<C-U>zz", { noremap = true, silent = true })

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

-- Delete swap files for current directory
vim.keymap.set("n", "<leader>os", function()
  local swap_dir = vim.fn.stdpath("state") .. "/swap"
  local all_swap_files = vim.fn.glob(swap_dir .. "/*", false, true)

  if #all_swap_files == 0 then
    print("No swap files found")
    return
  end

  -- Get current working directory and encode it (/ becomes %)
  local cwd = vim.fn.getcwd()
  local encoded_cwd = cwd:gsub("/", "%%")

  -- Filter swap files that belong to current directory
  local matching_files = {}
  for _, file in ipairs(all_swap_files) do
    local filename = vim.fn.fnamemodify(file, ":t")
    -- Check if the swap file's encoded path starts with our encoded cwd
    if filename:find(encoded_cwd, 1, true) then
      table.insert(matching_files, file)
    end
  end

  if #matching_files == 0 then
    print("No swap files found for current directory")
    return
  end

  local confirm = vim.fn.confirm(
    string.format("Delete %d swap file(s) for current directory?", #matching_files),
    "&Yes\n&No",
    2
  )

  if confirm ~= 1 then
    print("Cancelled")
    return
  end

  local count = 0
  for _, file in ipairs(matching_files) do
    if vim.fn.delete(file) == 0 then
      count = count + 1
    end
  end

  print(string.format("Deleted %d swap file(s)", count))
end, { noremap = true, desc = "Delete swap files for current directory" })
