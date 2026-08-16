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
    window = {
      width = 30,
    },
    filesystem = {
      follow_current_file = { enabled = true },
      hijack_netrw_behavior = "disabled",
      use_libuv_file_watcher = true,
      cwd_target = {
        sidebar = "tab",   -- sidebar follows tab's cwd
      },
      filtered_items = {
        visible = true,        -- show hidden/filtered items, just styled differently
        hide_dotfiles = false, -- don't hide dot-prefixed files
        hide_gitignored = false, -- show gitignored files (dimmed)
      },
      commands = {
        -- Override the default "delete" (bound to "d") to move to trash instead of `rm -Rf`
        delete = function(state)
          local node = state.tree:get_node()
          if node.type ~= "file" and node.type ~= "directory" then
            return
          end
          local trash_cmd = (vim.uv or vim.loop).os_uname().sysname == "Darwin"
              and { "trash", node.path }
              or { "gio", "trash", node.path }
          require("neo-tree.ui.inputs").confirm(
            "Move '" .. node.name .. "' to trash?",
            function(confirmed)
              if not confirmed then return end
              vim.fn.system(trash_cmd)
              if vim.v.shell_error ~= 0 then
                vim.notify("Failed to move to trash: " .. node.path, vim.log.levels.ERROR)
              end
              -- use_libuv_file_watcher (above) auto-refreshes the tree once the file disappears
            end
          )
        end,
      },
    },
  },
}
