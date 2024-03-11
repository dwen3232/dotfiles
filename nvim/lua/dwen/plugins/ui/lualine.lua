return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status") -- to configure lazy pending updates count

    lualine.setup({
      options = {
        theme = "nightfly",
      },
      sections = {
        -- TODO: customize this more, there's a lot that can be done!
        lualine_c = {
          { 
            'filename', 
            file_status = true,  -- display file status (readonly status, modified status)
            path = 1  -- 0 = just filename, 1 = relative path, 2 = absolute path
          }
        }, 
        lualine_x = {
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = "#ff9e64" },
          },
          { "encoding" },
          { "fileformat" },
          { "filetype" },
        },
      },
    })
  end,
}
