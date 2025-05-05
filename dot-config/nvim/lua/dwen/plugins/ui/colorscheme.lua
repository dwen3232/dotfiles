return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    vim.cmd([[colorscheme catppuccin]])
  end,
  ---@type CatppuccinOptions
  opts = {
    integrations = {
      blink_cmp = true,
    },
  },
}

