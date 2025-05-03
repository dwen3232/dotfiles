return {
  "olimorris/codecompanion.nvim",
  dependencies = {
  "ravitemer/mcphub.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "j-hui/fidget.nvim",
  },
  keys = {
    {
      "<leader>ll",
      "<cmd>CodeCompanionChat toggle<CR>",
      desc = "Toggle Chat Buffer",
    },
    {
      "<leader>ln",
      "<cmd>CodeCompanionChat toggle<CR>",
      desc = "New Chat Buffer",
    },
    {
      "<leader>la",
      "<cmd>CodeCompanionAction<CR>",
      desc = "Code Companion Actions",
    },
  },
  opts = {
    extensions = {
      mcphub = {
        callback = "mcphub.extensions.codecompanion",
        opts = {
          show_result_in_chat = true, -- Show the mcp tool result in the chat buffer
          make_vars = true, -- make chat #variables from MCP server resources
          make_slash_commands = true, -- make /slash_commands from MCP server prompts
        },
      },
    },
    strategies = {
      -- Change the default chat adapter
      inline = { adapter = "anthropic" },
      chat = {
        adapter = "anthropic",
        keymaps = {
          send = {
            modes = { n = "<C-s>", i = "<C-s>" },
          },
          close = {
            modes = { n = "<C-q>", i = "<C-q>" },
          },
        },
      },
    },

    display = {
      chat = {
        window = {
          layout = "vertical", -- float|vertical|horizontal|buffer
          position = "right", -- left|right|top|bottom (nil will default depending on vim.opt.plitright|vim.opt.splitbelow)
          -- border = "single",
          -- height = 0.8,
          -- width = 0.45,
          -- relative = "editor",
          -- full_height = true, -- when set to false, vsplit will be used to open the chat buffer vs. botright/topleft vsplit
          -- opts = {
          --   breakindent = true,
          --   cursorcolumn = false,
          --   cursorline = false,
          --   foldcolumn = "0",
          --   linebreak = true,
          --   list = false,
          --   numberwidth = 1,
          --   signcolumn = "no",
          --   spell = false,
          --   wrap = true,
          -- },
        },
      },
    },
  },
  init = function()
    require("dwen.plugins.ai.codecompanion.fidget-spinner"):init()
  end,
}
