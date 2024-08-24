return {
  "rcarriga/nvim-notify",
  config = function()
    local notify = require("notify")

    notify.setup({
      background_colour = "NotifyBackground",
      fps = 30,
      icons = {
        DEBUG = "",
        ERROR = "",
        INFO = "",
        TRACE = "✎",
        WARN = "",
      },
      level = 2,
      minimum_width = 50,
      max_width = 60,
      render = "default",
      stages = "fade",
      time_formats = {
        notification = "%T",
        notification_history = "%FT%T",
      },
      timeout = 2500,
      top_down = true,
    })

    function CLOSE_ALL_NOTIFICATIONS()
      notify.dismiss({ pending = true, silent = true })
    end

    local opts = { noremap = true, silent = true }
    vim.api.nvim_set_keymap("n", "<Esc>", ":lua CLOSE_ALL_NOTIFICATIONS()<CR>", opts)
    vim.api.nvim_set_keymap("n", "<C-c>", ":lua CLOSE_ALL_NOTIFICATIONS()<CR>", opts)
  end,
}
