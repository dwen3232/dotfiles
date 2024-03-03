return {
  "windwp/nvim-ts-autotag",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    autotag = require("nvim-ts-autotag")
    autotag.setup()
  end,
}
