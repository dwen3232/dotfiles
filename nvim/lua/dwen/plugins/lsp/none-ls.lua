return {
	"nvimtools/none-ls.nvim",
	-- lazy = true,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"williamboman/mason.nvim",
	},
	config = function()
		local null_ls = require("null-ls")

		local diagnostics = null_ls.builtins.diagnostics
		local formatting = null_ls.builtins.formatting

		local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

		-- https://github.com/nvimtools/none-ls.nvim/blob/main/doc/BUILTINS.md
		null_ls.setup({
			sources = {
				-- lua
				-- formatting.stylua,
				-- python
				diagnostics.mypy,
				diagnostics.ruff,
				formatting.ruff_format,
				formatting.isort,
			}, -- configure format on save
			on_attach = function(current_client, bufnr)
				if current_client.supports_method("textDocument/formatting") then
					vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = augroup,
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.format({
								filter = function(client)
									--  only use null-ls for formatting instead of lsp server
									return client.name == "null-ls"
								end,
								bufnr = bufnr,
							})
						end,
					})
				end
			end,
		})
	end,
}
