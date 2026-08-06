-- Bootstrap lazy.nvim (auto-installs if missing)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load settings
require("core.options")

-- Load all plugins from lua/plugins/
require("lazy").setup("plugins")

vim.opt.splitbelow = true   -- horizontal splits always go below
vim.opt.splitright = true   -- vertical splits always go right


vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function()
    vim.opt_local.modifiable = true
    vim.cmd("startinsert")   -- auto enters insert mode when terminal opens
  end,
})

-- Keybindings

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left pane" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right pane" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom pane" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top pane" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

--- terminal
local terminal_buf = -1
local terminal_win = -1

local function term_height()
  return math.floor(vim.o.lines * 0.25)  -- 25% of total nvim height
end

vim.keymap.set({ "n", "t" }, "<C-j>", function()
  if vim.api.nvim_win_is_valid(terminal_win) then
    vim.api.nvim_win_close(terminal_win, false)
    terminal_win = -1
    return
  end

  if not vim.api.nvim_buf_is_valid(terminal_buf) then
    vim.cmd("below sp | terminal")
    vim.cmd("resize " .. term_height())
    terminal_buf = vim.api.nvim_get_current_buf()
    terminal_win = vim.api.nvim_get_current_win()
    vim.cmd("startinsert")
    return
  end

  vim.cmd("below sb " .. terminal_buf)
  vim.cmd("resize " .. term_height())
  terminal_win = vim.api.nvim_get_current_win()
  vim.cmd("startinsert")
end, { desc = "Toggle terminal" })

-- Autoload
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  pattern = "*",
  command = "checktime",
})
