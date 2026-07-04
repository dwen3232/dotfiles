local function buffer_cwd()
  local buffer_path = vim.api.nvim_buf_get_name(0)

  if buffer_path == "" or vim.bo.buftype ~= "" then
    return vim.fn.getcwd()
  end

  return vim.fs.dirname(buffer_path)
end

return {
  "danielfalk/smart-open.nvim",
  dependencies = {
    "kkharji/sqlite.lua",
    -- Only required if using match_algorithm fzf
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    -- Optional.  If installed, native fzy will be used when match_algorithm is fzy
    { "nvim-telescope/telescope-fzy-native.nvim" },
  },
  branch = "0.2.x",
  config = function()
    require("telescope").load_extension("smart_open")
  end,
  keys = {
    {
      "<leader><leader>",
      function()
        require("telescope").extensions.smart_open.smart_open({
          cwd_only = true,
        })
      end,
      desc = "Smart Find",
    },
    {
      "<leader>fc",
      function()
        require("telescope").extensions.smart_open.smart_open({
          cwd = buffer_cwd(),
          cwd_only = true,
        })
      end,
      desc = "Smart Find in Buffer CWD",
    },
  },
}
