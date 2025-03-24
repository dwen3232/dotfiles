-- TODO: need to set up more sensible navigation for GpChatFinder popup
return {
  "robitx/gp.nvim",
  config = function()
    local gp = require("gp")

    gp.setup({
      providers = {
        anthropic = {
          disable = false,
          endpoint = "https://api.anthropic.com/v1/messages",
          secret = os.getenv("ANTHROPIC_API_KEY"),
        },
      },
      agents = {
        {
          provider = "anthropic",
          name = "SonnetMLE",
          chat = true,
          command = false,
          -- string with model name or table with model name and parameters
          model = { model = "claude-3-5-sonnet-20241022", temperature = 0.8, top_p = 1 },
          -- system prompt (use this to specify the persona/role of the AI)
          system_prompt = require("dwen.prompts.machine-learning-engineer"),
        },
      },
      hooks = {
        Explain = function(plugin, params)
          local template = "I have the following code from {{filename}}:\n\n"
            .. "```{{filetype}}\n{{selection}}\n```\n\n"
            .. "Please respond by explaining the code above."
          local agent = plugin.get_chat_agent()
          plugin.Prompt(params, plugin.Target.popup, agent, template)
        end,
      },
      default_chat_agent = "SonnetMLE",
      default_command_agent = "CodeClaude-3-5-Sonnet",
    })
    local keymap = vim.keymap

    keymap.set("n", "<leader>ln", "<cmd>GpChatNew popup<cr>", { desc = "Create new LLM chat" })
    keymap.set("v", "<leader>ln", ":'<,'>GpChatNew popup<cr>", { desc = "Create new LLM chat with selection" })
    keymap.set("n", "<leader>ll", "<cmd>GpChatToggle popup<cr>", { desc = "Toggle last active LLM chat" })
    keymap.set("n", "<leader>lf", "<cmd>GpChatFinder<cr>", { desc = "Find LLM chat" })
    keymap.set("n", "<leader>fl", "<cmd>GpChatFinder<cr>", { desc = "Find LLM chat" })
    keymap.set("n", "<leader>le", "<cmd>GpExplain<cr>", { desc = "Explain the current line" })
    keymap.set("v", "<leader>le", ":'<,'>GpExplain<CR>", { desc = "Explain the selection" })
  end,
}
