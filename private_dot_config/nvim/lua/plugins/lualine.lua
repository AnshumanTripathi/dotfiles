return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  lazy = false,
  opts = {
    options = {
      theme = "auto",
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = { { "filename", path = 1 } },  -- relative path
      lualine_x = { "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
  },
}
