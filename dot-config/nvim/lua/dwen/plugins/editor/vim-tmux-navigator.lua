local function herdr_pane_focus(direction)
  local herdr = vim.env.HERDR_BIN_PATH or "herdr"
  local pane_id = vim.env.HERDR_PANE_ID
  local args = { herdr, "pane", "focus", "--direction", direction }

  if pane_id ~= nil and pane_id ~= "" then
    vim.list_extend(args, { "--pane", pane_id })
  else
    vim.list_extend(args, { "--current" })
  end

  local job_id = vim.fn.jobstart(args, {
    detach = true,
  })

  return job_id > 0
end

local function tmux_navigate(command)
  if vim.env.TMUX == nil or vim.env.TMUX == "" then
    return false
  end

  if vim.fn.exists(":" .. command) == 0 then
    return false
  end

  vim.cmd("silent! " .. command)
  return true
end

local function navigate(wincmd, herdr_direction, tmux_command)
  local current_win = vim.api.nvim_get_current_win()

  vim.cmd("wincmd " .. wincmd)

  if vim.api.nvim_get_current_win() ~= current_win then
    return
  end

  if tmux_navigate(tmux_command) then
    return
  end

  herdr_pane_focus(herdr_direction)
end

return {
  "christoomey/vim-tmux-navigator",
  init = function()
    vim.g.tmux_navigator_no_mappings = 1
  end,
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  keys = {
    { "<c-h>", function() navigate("h", "left", "TmuxNavigateLeft") end },
    { "<c-j>", function() navigate("j", "down", "TmuxNavigateDown") end },
    { "<c-k>", function() navigate("k", "up", "TmuxNavigateUp") end },
    { "<c-l>", function() navigate("l", "right", "TmuxNavigateRight") end },
    { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
  },
}
