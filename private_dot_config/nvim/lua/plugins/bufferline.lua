return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",
  event = "VeryLazy",
  keys = {
    { "<Tab>",       "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    { "<S-Tab>",     "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
    { "<leader>bd",  "<cmd>bdelete<cr>",             desc = "Close buffer" },
  },
  opts = {
    options = {
      diagnostics = "nvim_lsp",         -- shows error/warning count on tab
      show_buffer_close_icons = true,
      show_close_icon = false,
      separator_style = "slant",        -- slant | thick | thin
    },
  },
}
