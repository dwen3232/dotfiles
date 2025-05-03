local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { import = "dwen.plugins" },
  { import = "dwen.plugins.coding" },
  { import = "dwen.plugins.editor" },
  { import = "dwen.plugins.formatting" },
  { import = "dwen.plugins.linting" },
  { import = "dwen.plugins.lsp" },
  { import = "dwen.plugins.testing" },
  { import = "dwen.plugins.ui" },
  { import = "dwen.plugins.ai",}
}, {
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
})
