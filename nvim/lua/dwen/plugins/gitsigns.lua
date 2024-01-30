-- TODO: configure custom gitsigns, the default ones are kinda weird
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = true,
}
