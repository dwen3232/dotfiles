return {
  -- see the image.nvim readme for more information about configuring this plugin
  "3rd/image.nvim",
  opts = {
    backend = "kitty", -- whatever backend you would like to use
    integrations = {
      markdown = {
        enabled = true,
        clear_in_insert_mode = false,
        download_remote_images = true,
        only_render_image_at_cursor = false,
        filetypes = { "markdown" }, -- markdown extensions (ie. quarto) can go here
      },
      html = {
        enabled = true,
      },
    },
    max_width = nil,
    max_height = nil,
    -- max_height_window_percentage = math.huge,
    -- max_width_window_percentage = math.huge,
    window_overlap_clear_enabled = false, -- toggles images when windows are overlapped
    window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
    editor_only_render_when_focused = false, -- auto show/hide images when the editor gains/looses focus
    tmux_show_only_in_active_window = false, -- auto show/hide images in the correct Tmux window (needs visual-activity off)
    hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" }, -- render image files as images when opened
  },
}
