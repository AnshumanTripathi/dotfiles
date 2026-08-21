return {
  {
    "navarasu/onedark.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      if vim.g.active_theme == "onedark" then
        require("onedark").setup { style = "deep" }
        require("onedark").load()
      end
    end,
  },
  {
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
      if vim.g.active_theme == "catppuccin" then
        require("catppuccin").setup(opts)
        vim.cmd("colorscheme catppuccin")
      end
    end,
  },
}
