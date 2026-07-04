local M = {}

local directions = {
  left = "h",
  down = "j",
  up = "k",
  right = "l",
}

local function herdr_available()
  return vim.env.HERDR_ENV == "1" and vim.fn.executable(vim.env.HERDR_BIN_PATH or "herdr") == 1
end

function M.focus_herdr_pane(direction)
  if not herdr_available() then
    return false
  end

  local herdr = vim.env.HERDR_BIN_PATH or "herdr"
  local pane_id = vim.env.HERDR_PANE_ID
  local args = { herdr, "pane", "focus", "--direction", direction }

  if pane_id ~= nil and pane_id ~= "" then
    vim.list_extend(args, { "--pane", pane_id })
  else
    vim.list_extend(args, { "--current" })
  end

  return vim.fn.jobstart(args, { detach = true }) > 0
end

function M.navigate(direction)
  local wincmd = directions[direction]

  if wincmd == nil then
    return false
  end

  local current_win = vim.api.nvim_get_current_win()

  vim.cmd("wincmd " .. wincmd)

  if vim.api.nvim_get_current_win() ~= current_win then
    return true
  end

  return M.focus_herdr_pane(direction)
end

function M.setup_keymaps(opts)
  opts = opts or {}

  local mode = opts.mode or "n"
  local buffer = opts.buffer
  local herdr_only = opts.herdr_only or false
  local keymap_opts = {
    noremap = true,
    silent = true,
  }

  if buffer ~= nil then
    keymap_opts.buffer = buffer
  end

  local mappings = {
    { "<C-h>", "left", "Navigate left" },
    { "<C-j>", "down", "Navigate down" },
    { "<C-k>", "up", "Navigate up" },
    { "<C-l>", "right", "Navigate right" },
  }

  for _, mapping in ipairs(mappings) do
    local lhs = mapping[1]
    local direction = mapping[2]
    local desc = mapping[3]

    keymap_opts.desc = desc
    vim.keymap.set(mode, lhs, function()
      if herdr_only then
        M.focus_herdr_pane(direction)
      else
        M.navigate(direction)
      end
    end, vim.deepcopy(keymap_opts))
  end
end

return M
