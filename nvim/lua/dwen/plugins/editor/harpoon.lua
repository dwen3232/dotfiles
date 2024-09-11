return {
  "ThePrimeagen/harpoon",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    local harpoon = require("harpoon")
    local telescope = require("telescope")
    harpoon.setup()
    telescope.load_extension("harpoon")
  end,
  keys = {
    { "<leader>ha", [[ <cmd>lua require("harpoon.mark").add_file()<cr> ]], desc = "Mark current file" },
    { "<leader>hd", [[ <cmd>lua require("harpoon.mark").rm_file()<cr> ]], desc = "Remove current file" },
    { "<leader>hh", [[ <cmd>Telescope harpoon marks<cr> ]], desc = "Find marks" },
    { "<leader>fh", [[ <cmd>Telescope harpoon marks<cr> ]], desc = "Find marks" },
    { "<leader>hq", [[ <cmd>lua require("harpoon.ui").nav_file(1)<cr> ]], desc = "Go to Mark 1" },
    { "<leader>hw", [[ <cmd>lua require("harpoon.ui").nav_file(2)<cr> ]], desc = "Go to Mark 2" },
    { "<leader>he", [[ <cmd>lua require("harpoon.ui").nav_file(3)<cr> ]], desc = "Go to Mark 3" },
    { "<leader>hr", [[ <cmd>lua require("harpoon.ui").nav_file(4)<cr> ]], desc = "Go to Mark 4" },
    { "<leader>ht", [[ <cmd>lua require("harpoon.ui").nav_file(5)<cr> ]], desc = "Go to Mark 5" },
  },
}
