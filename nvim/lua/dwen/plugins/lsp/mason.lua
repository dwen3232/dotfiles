-- Setup for Mason and all of its adapters
return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "jay-babu/mason-null-ls.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    -- import mason
    local mason = require("mason")

    -- import mason-lspconfig
    local mason_lspconfig = require("mason-lspconfig")
    local mason_null_ls = require("mason-null-ls")
    local mason_tool_installer = require("mason-tool-installer")

    -- enable mason and configure icons
    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mason_lspconfig.setup({
      -- list of servers for mason to install
      ensure_installed = {
        "tsserver",
        "html",
        "cssls",
        "tailwindcss",
        "lua_ls",
        "pyright",
      },
      -- auto-install configured servers (with lspconfig)
      automatic_installation = true, -- not the same as ensure_installed
    })

    -- NOTE: couldn't get none-ls to use local linters because of $PATH order (maybe?),
    -- easiest solution is to just not install linters to mason dir
    mason_null_ls.setup({
      ensure_installed = {
        -- "sonarlint-language-server",
        -- "isort",
        -- "ruff",
        -- "mypy",
      },
    })

    mason_tool_installer.setup({
      ensure_installed = {
        -- "prettier",
        -- "stylua",
        -- "ruff",
      },
    })
  end,
}
