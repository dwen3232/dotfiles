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
      desc = "Show current buffer diagnostics",
    },
    {
      "<leader>xa",
      "<cmd>Trouble diagnostics toggle<cr>",
      desc = "Show all diagnostics",
    },
  },
}
