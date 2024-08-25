-- TODO: can't seem to get these autocmds to work correctly
return {
  "folke/persistence.nvim",
  config = function()
    local persist = require("persistence")

    persist.setup()

    -- vim.api.nvim_create_autocmd({ "BufEnter" }, {
    --   group = vim.api.nvim_create_augroup("AutoSaveSession", { clear = true }),
    --   callback = function()
    --     require("persistence").save()
    --   end,
    -- })
    --
    -- -- This doesn't seem to work
    -- vim.api.nvim_create_autocmd("VimEnter", {
    --   group = vim.api.nvim_create_augroup("AutoLoadSession", { clear = true }),
    --   callback = function()
    --     require("persistence").load()
    --   end,
    -- })

    -- load the session for the current directory
    vim.keymap.set("n", "<leader>qs", function()
      persist.save()
    end, { desc = "Save current directory session" })

    -- select a session to load
    vim.keymap.set("n", "<leader>qf", function()
      persist.select()
    end, { desc = "Select session to load" })

    -- load the last session
    vim.keymap.set("n", "<leader>ql", function()
      persist.load({ last = true })
    end, { desc = "Load last session" })
  end,
}
