-- TODO: set this up
return {
  "zbirenbaum/copilot.lua",
  event = { "InsertEnter" },
  config = function()
    local copilot = require("copilot")
    copilot.setup()
  end,
}
