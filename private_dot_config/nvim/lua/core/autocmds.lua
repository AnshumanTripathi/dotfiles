-- Ensure files always end with a blank line on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    local last_line = vim.fn.line("$")
    if vim.fn.getline(last_line) ~= "" then
      vim.fn.append(last_line, "")
    end
  end,
})

-- Enter insert mode when opening a terminal buffer
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function()
    vim.opt_local.modifiable = true
    vim.cmd("startinsert")
  end,
})

-- Reload file when changed externally
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  pattern = "*",
  command = "checktime",
})

-- Autosave on leaving insert mode or text change
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  pattern = "*",
  command = "silent! write",
})

-- Open neo-tree on startup when no file (or only a directory) is given
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    local argc = vim.fn.argc()
    local is_dir = argc == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1
    if argc == 0 or is_dir then
      vim.cmd("Neotree filesystem focus left")
    end
  end,
})
