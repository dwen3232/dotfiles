-- Custom commands

-- Command to clean Neovim cache and lazy plugin directory
vim.api.nvim_create_user_command("CleanLazyLock", function()
	local lazy_dir = vim.fn.expand("~/.local/share/nvim/lazy")
	local cache_dir = vim.fn.expand("~/.cache/nvim/luac")

	-- Delete lazy plugin directory
	if vim.fn.isdirectory(lazy_dir) == 1 then
		vim.fn.delete(lazy_dir, "rf")
		print("Deleted: " .. lazy_dir)
	else
		print("Directory not found: " .. lazy_dir)
	end

	-- Delete luac cache directory
	if vim.fn.isdirectory(cache_dir) == 1 then
		vim.fn.delete(cache_dir, "rf")
		print("Deleted: " .. cache_dir)
	else
		print("Directory not found: " .. cache_dir)
	end

	print("Neovim cleanup complete!")
end, {
	desc = "Delete lazy plugin directory and luac cache",
})
