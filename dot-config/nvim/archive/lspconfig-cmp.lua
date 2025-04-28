return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "folke/neodev.nvim",
    { "antosha417/nvim-lsp-file-operations", config = true },
  },
  config = function()
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local neodev = require("neodev")

    -- neodev needs to be configured before lspconfig
    neodev.setup({})

    local keymap = vim.keymap -- for conciseness

    -- local opts = { noremap = true, silent = true }
    local opts = { noremap = true }
    local on_attach = function(_, bufnr)
      opts.buffer = bufnr

      -- set keybinds
      opts.desc = "Show LSP references"
      keymap.set("n", "<leader>gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

      opts.desc = "Go to declaration"
      keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, opts) -- go to declaration

      opts.desc = "Show LSP definitions"
      keymap.set("n", "<leader>gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

      opts.desc = "Show LSP implementations"
      keymap.set("n", "<leader>gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

      opts.desc = "Show LSP type definitions"
      keymap.set("n", "<leader>gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

      opts.desc = "Fuzzy find diagnostics in buffer"
      keymap.set("n", "<leader>fd", "<cmd>Telescope diagnostics<CR>", opts) -- show  diagnostics for file

      opts.desc = "Go to previous diagnostic"
      keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

      opts.desc = "Go to next diagnostic"
      keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

      opts.desc = "Show documentation for what is under cursor"
      keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

      -- LSP
      opts.desc = "See available code actions"
      keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

      opts.desc = "Smart rename"
      keymap.set("n", "<leader>cn", vim.lsp.buf.rename, opts) -- smart rename

      opts.desc = "Restart LSP"
      keymap.set("n", "<leader>cr", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary

      local function toggle_diagnostics()
        vim.diagnostic.enable(not vim.diagnostic.is_enabled())
      end

      opts.desc = "Toggle diagnostics"
      keymap.set("n", "<leader>cd", toggle_diagnostics, opts)
    end

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Change the Diagnostic symbols in the sign column (gutter)
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    vim.lsp.enable({
      "html",
      "ts_ls",
      "cssls",
      "tailwindcss",
      "eslint",
      "pyright",
      "terraformls",
      "gopls",
      "bashls",
      "sqlls",
      "dockerls",
      "lua_ls",
    })

    vim.lsp.config("*", {
      capabilities = capabilities,
      on_attach = on_attach,
    })

    vim.lsp.config("pyright", {
      capabilities = capabilities,
      on_attach = on_attach,
      flags = {
        debounce_text_changes = 200, -- in milis
      },
    })

    -- configure lua server (with special settings)
    vim.lsp.config("lua_ls", {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = { -- custom settings for lua
        Lua = {
          -- make the language server recognize "vim" global
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            -- make language server aware of runtime files
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.stdpath("config") .. "/lua"] = true,
            },
          },
        },
      },
    })
  end,
}
