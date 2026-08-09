return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("nvim-treesitter").setup()
    -- Disable markdown injections to avoid Neovim 0.12.4 range() bug
    -- with embedded language parsing in code fences
    vim.treesitter.query.set("markdown", "injections", "")
  end,
}
