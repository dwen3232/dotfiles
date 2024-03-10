return {
  "folke/which-key.nvim",
  event = "VeryLazy",

  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    wk.register({
      ["<leader>"] = { name = "+leader" },
      ["<leader>c"] = { name = "+code" },
      ["<leader>d"] = { name = "+debug" },
      ["<leader>e"] = { name = "+explore" },
      ["<leader>f"] = { name = "+find" },
      ["<leader>t"] = { name = "+test" },
      ["<leader>x"] = { name = "+diagnostics" },
    })
  end,
}
