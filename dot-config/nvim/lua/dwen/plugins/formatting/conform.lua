return {
  "stevearc/conform.nvim",
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_fix", "ruff_format" },
        html = { "prettier" },
        css = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        javascriptreact = { "prettier" },
        rust = { "rustfmt" },
        terraform = { "terraform_fmt" },
        go = { "gofumpt" },
      },
    })

    -- Formatter specific configs
    conform.formatters.stylua = {
      prepend_args = {
        "--indent-type",
        "Spaces",
        "--indent-width",
        "2",
      },
    }

    local format_augroup = vim.api.nvim_create_augroup("format", { clear = true })

    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      pattern = "*",
      group = format_augroup,
      callback = function(args)
        conform.format({ bufnr = args.buf })
      end,
    })

    vim.keymap.set("n", "<leader>cf", function()
      conform.format()
    end, { desc = "Trigger formatting" })
  end,
}
