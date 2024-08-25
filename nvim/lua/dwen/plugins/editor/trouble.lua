-- TODO: I honestly don't like this that much, I think I can just replace this with lspsaga
return {
  "folke/trouble.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  opts = {},
  cmd = "Trouble",
  keys = {
    {
      "<leader>xd",
      "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
      desc = "Show Current Buffer Diagnostics",
    },
    {
      "<leader>xa",
      "<cmd>Trouble diagnostics toggle<cr>",
      desc = "Show All Diagnostics",
    },
  },
}
