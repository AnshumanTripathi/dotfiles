return {
  "nvim-telescope/telescope.nvim",
  branch = "master",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  config = function()
    local telescope = require("telescope")
    local builtin = require("telescope.builtin")

    telescope.setup({
      defaults = {
        file_ignore_patterns = { "node_modules", ".git/", "dist/", "build/" },
      },
      extensions = {
        fzf = {},
      },
    })

    telescope.load_extension("fzf")

    vim.keymap.set("n", "<leader>ff", function()
      builtin.find_files({
        find_command = { "fd", "--type", "f", "--hidden", "--no-ignore", "--exclude", ".git" },
      })
    end, { desc = "Find files" })

    vim.keymap.set("n", "<leader>fg", builtin.live_grep,  { desc = "Live grep" })
    vim.keymap.set("n", "<leader>fb", builtin.buffers,    { desc = "Find buffers" })
    vim.keymap.set("n", "<leader>fh", builtin.help_tags,  { desc = "Help tags" })
    vim.keymap.set("n", "<leader>fr", builtin.oldfiles,   { desc = "Recent files" })
  end,
}
