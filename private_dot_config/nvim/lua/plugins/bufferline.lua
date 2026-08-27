return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",
  event = "VeryLazy",
  keys = {
    { "<Tab>",       "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    { "<S-Tab>",     "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
    { "<leader>bd", function()
      local cur = vim.api.nvim_get_current_buf()
      local bufs = vim.fn.getbufinfo({ buflisted = 1 })
      if #bufs <= 1 then
        vim.cmd("enew")       -- last buffer: open blank so focus stays in main window
      else
        vim.cmd("bprevious")  -- skips unlisted buffers (neo-tree, terminals, etc.)
      end
      vim.api.nvim_buf_delete(cur, { force = false })
    end, desc = "Close buffer" },
    { "<leader>bp",  "<cmd>BufferLinePick<cr>",      desc = "Pick buffer to switch to" },
    { "<leader>bx",  "<cmd>BufferLinePickClose<cr>", desc = "Pick buffer to close" },
    { "<leader>bo",  "<cmd>BufferLineCloseOthers<cr>", desc = "Close other buffers" },
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
