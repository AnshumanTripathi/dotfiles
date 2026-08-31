-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Pane navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left pane" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right pane" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom pane" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top pane" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Terminal toggle (<C-j> overrides pane-down in n/t modes)
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

  if vim.bo.filetype == "neo-tree" then
    vim.cmd("wincmd p")
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

-- Duplicate line (VS Code style: Shift+Alt+Down/Up)
vim.keymap.set("n", "<S-M-Down>", "yyp",  { desc = "Duplicate line down" })
vim.keymap.set("n", "<S-M-Up>",   "yyP",  { desc = "Duplicate line up" })

-- Comment toggle (like Cmd+/ in VS Code)
vim.keymap.set("n", "<leader>/", "gcc", { desc = "Toggle comment", remap = true })
vim.keymap.set("v", "<leader>/", "gc",  { desc = "Toggle comment", remap = true })

-- File tree
vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Toggle file tree" })
vim.keymap.set("n", "<leader>r", "<cmd>Neotree focus<cr>",  { desc = "Focus file tree" })
