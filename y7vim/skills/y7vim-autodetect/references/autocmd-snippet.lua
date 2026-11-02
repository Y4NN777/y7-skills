-- Optional: fully-automatic detection on project open.
-- Paste into ~/.config/nvim/lua/config/autocmds.lua
--
-- Runs y7vim-autodetect's detect-and-enable.sh against the new cwd whenever
-- you change directory or open nvim, and reloads Lazy if it changed anything.
-- Requires the y7-skills repo checked out somewhere findable — adjust
-- Y7_SKILLS_PATH below.

local Y7_SKILLS_PATH = vim.fn.expand("~/code/y7-skills") -- <- adjust to where you cloned it
local SCRIPT = Y7_SKILLS_PATH .. "/skills/y7vim-autodetect/scripts/detect-and-enable.sh"

local function y7vim_autodetect()
  if vim.fn.executable(SCRIPT) ~= 1 then
    return
  end
  local cwd = vim.fn.getcwd()
  local before = vim.fn.readfile(vim.fn.stdpath("config") .. "/lazyvim.json")
  vim.fn.jobstart({ SCRIPT, cwd }, {
    on_exit = function()
      local after = vim.fn.readfile(vim.fn.stdpath("config") .. "/lazyvim.json")
      if table.concat(before, "\n") ~= table.concat(after, "\n") then
        vim.notify("y7vim-autodetect: new LazyVim extras enabled, run :Lazy sync", vim.log.levels.INFO)
      end
    end,
  })
end

vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
  callback = y7vim_autodetect,
  desc = "y7vim-autodetect: detect project tooling, enable matching LazyVim extras",
})
