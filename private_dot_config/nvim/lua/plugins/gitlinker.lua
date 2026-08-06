return {
  "ruifm/gitlinker.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("gitlinker").setup({
      callbacks = {
        ["gitlab.corp.zscaler.com"] = require("gitlinker.hosts").get_gitlab_type_url,
      },
      action_callback = require("gitlinker.actions").open_in_browser, -- opens in browser instead of copying
      mappings = "<leader>gy",
    })
  end,
}
