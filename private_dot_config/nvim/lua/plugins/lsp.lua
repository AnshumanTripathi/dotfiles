return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()

      local lspconfig = require("lspconfig")

      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "ts_ls", "gopls", "terraformls" },
        automatic_installation = true,
        handlers = {
          -- Default handler — runs for every installed server
          function(server_name)
            lspconfig[server_name].setup({
              capabilities = require("cmp_nvim_lsp").default_capabilities(),
            })
          end,

          -- Per-server overrides go here, e.g.:
          -- ["lua_ls"] = function()
          --   lspconfig.lua_ls.setup({
          --     settings = { Lua = { diagnostics = { globals = { "vim" } } } }
          --   })
          -- end,
        },
      })

      -- LSP keymaps (active only in buffers with an attached LSP)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "gd",         vim.lsp.buf.definition,   opts)
          vim.keymap.set("n", "gD",         vim.lsp.buf.declaration,  opts)
          vim.keymap.set("n", "gi",         vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "gr",         vim.lsp.buf.references,   opts)
          vim.keymap.set("n", "K",          vim.lsp.buf.hover,        opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,       opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action,  opts)
          vim.keymap.set("n", "<leader>d",  vim.diagnostic.open_float, opts)
          vim.keymap.set("n", "[d",         vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "]d",         vim.diagnostic.goto_next, opts)
        end,
      })
    end,
  },
}
