return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      python = { "ruff", "mypy" },
      json = { "jsonlint" },
      dockerfile = { "hadolint" },
      terraform = { "tflint" },
      yaml = { "actionlint" },
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    -- NOTE: 'InsertLeave' does not work with linters that require the file to be
    -- saved. You can check this by checking the 'stdin' flag in this plugin's source
    -- If 'stdin=false', then it will not work
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      pattern = "*", -- apply to all files
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })

    vim.keymap.set("n", "<leader>cl", function()
      lint.try_lint()
    end, { desc = "Trigger linting" })
  end,
}
