return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    -- v1.0: setup() only accepts optional { install_dir }
    require("nvim-treesitter").setup()
    -- Install parsers (! = skip if already installed)
    vim.cmd("TSInstall! lua javascript typescript tsx html css json bash markdown")
  end,
}
