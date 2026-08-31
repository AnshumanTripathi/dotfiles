-- Options are automatically loaded before lazy.nvim startup.
require("config.remote_clipboard").setup()

vim.g.autoformat = false -- Omarchy default: no format-on-save surprises (flip to true for LazyVim's formatters)
vim.g.active_theme = "onedark" -- "onedark" | "catppuccin" (only used on non-Omarchy machines, see coloscheme.lua)
