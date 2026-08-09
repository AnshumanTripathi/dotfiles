return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  lazy = false,
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle file explorer" },
  },

  opts = {
    filesystem = {
      follow_current_file = { enabled = true },
      hijack_netrw_behavior = "disabled",
      cwd_target = {
        sidebar = "tab",   -- sidebar follows tab's cwd
      },
      filtered_items = {
        visible = true,        -- show hidden/filtered items, just styled differently
        hide_dotfiles = false, -- don't hide dot-prefixed files
        hide_gitignored = false, -- show gitignored files (dimmed)
      },
    },
  },
}
