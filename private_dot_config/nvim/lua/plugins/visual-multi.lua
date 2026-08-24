return {
  "mg979/vim-visual-multi",
  branch = "master",
  init = function()
    vim.g.VM_maps = {
      ["Add Cursor Down"] = "<M-Down>",
      ["Add Cursor Up"]   = "<M-Up>",
    }
  end,
}
