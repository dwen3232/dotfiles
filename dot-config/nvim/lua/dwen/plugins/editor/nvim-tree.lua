return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local nvimtree = require("nvim-tree")
    local api = require("nvim-tree.api")

    -- disable netrw at the very start of your init.lua
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    -- OR setup with some options
    nvimtree.setup({
      on_attach = function(bufnr)
        api.config.mappings.default_on_attach(bufnr)

        vim.keymap.del("n", "<C-K>", { buffer = bufnr })
      end,
      actions = {
        open_file = {
          quit_on_open = true,
        },
      },
      sort = {
        sorter = "case_sensitive",
      },
      view = {
        width = 30,
        number = true,
        relativenumber = true,
      },
      renderer = {
        indent_markers = {
          enable = true,
        },
        icons = {
          glyphs = {
            folder = {
              arrow_closed = "↦", -- arrow when folder is closed
              arrow_open = "↧", -- arrow when folder is open
            },
          },
        },
      },
      filters = {
        git_ignored = false,
        custom = { ".DS_Store", "__pycache__" },
      },
    })

    local keymap = vim.keymap -- for conciseness

    keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" }) -- toggle file explorer
    keymap.set("n", "<leader>ef", function()
      local bufnr = vim.api.nvim_get_current_buf()

      api.tree.find_file({
        open = true,
        focus = true,
      })

      if vim.api.nvim_buf_is_valid(bufnr) and not api.tree.is_tree_buf(bufnr) then
        local ok, err = pcall(vim.api.nvim_buf_delete, bufnr, {})
        if not ok then
          vim.notify(err, vim.log.levels.ERROR)
        end
      end
    end, { desc = "Close buffer and reveal in file explorer" })
    keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" }) -- refresh file explorer
    keymap.set("n", "<leader>ei", api.node.show_info_popup, { desc = "Show file info" })
  end,
}
