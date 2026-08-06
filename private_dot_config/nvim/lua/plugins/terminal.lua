return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = {
    { "<leader>tt", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Toggle terminal" },
    { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>",      desc = "Floating terminal" },
    { "<leader>gg", desc = "Lazygit" },
  },
  config = function()
    require("toggleterm").setup({
      size = 15,
      shade_terminals = true,
    })

    -- Lazygit in a floating terminal
    local Terminal = require("toggleterm.terminal").Terminal
    local lazygit = Terminal:new({
      cmd = "lazygit",
      direction = "float",
      hidden = true,
    })

    vim.keymap.set("n", "<leader>gg", function()
      lazygit:toggle()
    end, { desc = "Lazygit" })
  end,
}
