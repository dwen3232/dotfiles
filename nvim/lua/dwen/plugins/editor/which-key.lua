return {
  "folke/which-key.nvim" ,
  event = "VeryLazy",

  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    wk.add(
      {
      {"<leader>c", group = "+code" },
      {"<leader>d", group = "+debug" },
      {"<leader>e", group = "+explore" },
      {"<leader>f", group = "+find" },
      {"<leader>h", group = "+harpoon" },
      {"<leader>t", group = "+test" },
      {"<leader>x", group = "+diagnostics" },}
    )
    -- wk.register({
    --   ["<leader>"] = { name = "+leader" },
    --   ["<leader>c"] = { name = "+code" },
    --   ["<leader>d"] = { name = "+debug" },
    --   ["<leader>e"] = { name = "+explore" },
    --   ["<leader>f"] = { name = "+find" },
    --   ["<leader>h"] = { name = "+harpoon" },
    --   ["<leader>t"] = { name = "+test" },
    --   ["<leader>x"] = { name = "+diagnostics" },
    -- })
  end,
}
