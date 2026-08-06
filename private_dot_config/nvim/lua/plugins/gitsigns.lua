return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },  -- lazy load when opening a file
  config = function()
    require("gitsigns").setup({
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 500,
        virt_text_pos = "eol",
      },
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = function(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

        -- Navigation
        map("n", "]h", gs.next_hunk,   "Next hunk")
        map("n", "[h", gs.prev_hunk,   "Prev hunk")

        -- Actions
        map("n", "<leader>gb", gs.toggle_current_line_blame, "Toggle git blame")
        map("n", "<leader>gp", gs.preview_hunk,              "Preview hunk")
        map("n", "<leader>gr", gs.reset_hunk,                "Reset hunk")
        map("n", "<leader>gs", gs.stage_hunk,                "Stage hunk")
      end,
    })
  end,
}
