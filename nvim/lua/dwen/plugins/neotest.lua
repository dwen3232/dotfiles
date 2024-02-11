return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    -- Adapters
    "nvim-neotest/neotest-python",
  },
  config = function()
    local neotest = require("neotest")

    --Adapters
    local pytest = require("neotest-python")

    neotest.setup({
      adapters = {
        pytest,
      },
    })

    local keymap = vim.keymap -- for conciseness
    local opts = { noremap = true, silent = true }

    opts.desc = "Run nearest test"
    keymap.set("n", "<leader>tt", function()
      neotest.run.run()
    end, opts)

    opts.desc = "Run the current file"
    keymap.set("n", "<leader>tf", function()
      neotest.run.run(vim.fn.expand("%"))
    end, opts)

    opts.desc = "Open test output window"
    keymap.set("n", "<leader>to", function()
      neotest.output.open({ enter = true, auto_close = true })
    end, opts)

    opts.desc = "Toggle test output panel"
    keymap.set("n", "<leader>tp", function()
      neotest.output_pannel.toggle()
    end, opts)

    opts.desc = "Stop nearest test"
    keymap.set("n", "<leader>ts", function()
      neotest.run.stop()
    end, opts)

    opts.desc = "Attach to nearest test"
    keymap.set("n", "<leader>ta", function()
      neotest.run.attach()
    end, opts)
  end,
}
