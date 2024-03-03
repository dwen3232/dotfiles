return {
  "folke/which-key.nvim",
  event = "VeryLazy",

  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    wk.register({
      ["<leader>"] = { name = "+leader" },
      ["<leader>f"] = { name = "+find" },
      ["<leader>e"] = { name = "+explore" },
      ["<leader>t"] = { name = "+trouble" },
      ["<leader>c"] = { name = "+code" },
    })
  end,
}
