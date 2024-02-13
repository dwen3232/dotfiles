-- TODO: a bunch of cool stuff here https://github.com/kevinhwang91/nvim-ufo?tab=readme-ov-file#setup-and-description
return {
  "kevinhwang91/nvim-ufo",
  dependencies = {
    "kevinhwang91/promise-async",
  },
  config = function()
    local nvim_ufo = require("ufo")

    nvim_ufo.setup({
      provider_selector = function(bufnr, filetype, buftype)
        return { "treesitter", "indent" }
      end,
    })
  end,
}
