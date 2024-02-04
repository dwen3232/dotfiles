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

    -- lspsaga.require({})
  end,
}
