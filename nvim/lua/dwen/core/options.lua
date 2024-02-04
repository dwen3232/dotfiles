local opt = vim.opt

-- TODO: refine all of these more
opt.relativenumber = true
opt.number = true

opt.expandtab = true -- tabs to spaces
opt.autoindent = true

opt.wrap = false

opt.cursorline = true

opt.hlsearch = true
opt.ignorecase = true
opt.smartcase = true

opt.signcolumn = "yes"

opt.clipboard:append("unnamedplus") -- use system clipboard as default register
