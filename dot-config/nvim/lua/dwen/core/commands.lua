-- Custom commands

-- Command to clean Neovim cache and lazy plugin directory
vim.api.nvim_create_user_command("CleanLazyLock", function()
	local lazy_dir = vim.fn.expand("~/.local/share/nvim/lazy")
	local cache_dir = vim.fn.expand("~/.cache/nvim/luac")

	-- Delete lazy plugin directory (except lazy.nvim itself to keep the plugin manager)
	if vim.fn.isdirectory(lazy_dir) == 1 then
		-- Get all plugin directories except lazy.nvim
		local plugins = vim.fn.readdir(lazy_dir)
		for _, plugin in ipairs(plugins) do
			if plugin ~= "lazy.nvim" then
				local plugin_path = lazy_dir .. "/" .. plugin
				vim.fn.delete(plugin_path, "rf")
				print("Deleted: " .. plugin_path)
			end
		end
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

	print("Neovim cleanup complete! Exiting...")

	-- Exit Neovim so user can restart and restore from lockfile
	vim.cmd("qall!")
end, {
	desc = "Delete lazy plugins and cache, then restore from lockfile",
})
