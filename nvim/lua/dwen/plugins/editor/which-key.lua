-- TODO: setup icons?
-- TODO: setup hints for nvim-tree, because I always forget what my bindings are there
return {
  "folke/which-key.nvim",
  event = "VeryLazy",

  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    wk.add({
      { "<leader>c", group = "+code" },
      { "<leader>d", group = "+debug" },
      { "<leader>e", group = "+explore" },
      { "<leader>f", group = "+find" },
      { "<leader>t", group = "+test" },
      { "<leader>x", group = "+diagnostics" },
      { "<leader>g", group = "+navigation" },
      { "<leader>l", group = "+ai" },
    })
  end,
}
