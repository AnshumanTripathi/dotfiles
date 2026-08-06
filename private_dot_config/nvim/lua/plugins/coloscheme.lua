return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  opts = {
    flavour = "mocha",  -- latte | frappe | macchiato | mocha
    transparent_background = false,
    integrations = {
      treesitter = true,
      telescope = { enabled = true },
      mason = true,
      cmp = true,
    },
  },
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd("colorscheme catppuccin")
  end,
}
