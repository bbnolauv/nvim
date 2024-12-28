return {
  {
    "neovim/nvim-lspconfig",
    -- event = { "BufReadPre", "BufNewFile" },
    ft = { "c", "cpp", "python", "lua" },
    config = function()
      local capabilities = {}
      local server = {
        "clangd",
        -- "cmake",
        -- "lua_ls",
        -- "pyright",
      }
      local lspcfg = require("lspconfig")
      for _, lsp in pairs(server) do
        lspcfg[lsp].setup({ capabilities = capabilities })
      end

      -- Disable lsp log
      vim.lsp.set_log_level("off")

      -- Global mappings.
      -- See `:help vim.diagnostic.*` for documentation on any of the below functions

      -- Use LspAttach autocommand to only map the following keys
      -- after the language server attaches to the current buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          -- Enable completion triggered by <c-x><c-o>
          vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

          -- Buffer local mappings.
          -- See `:help vim.lsp.*` for documentation on any of the below functions
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gR", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          -- vim.keymap.set("i", "<space>;", vim.lsp.buf.signature_help, opts)
          -- vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
          -- vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
          -- vim.keymap.set("n", "<space>wl", function()
          --   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          -- end, opts)
          -- vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
        end,
      })
    end,
  },
  {
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    -- keys = {
    --   { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
    --   { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
    --   { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
    --   {
    --     "<leader>cl",
    --     "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
    --     desc = "LSP Definitions / references / ... (Trouble)",
    --   },
    --   { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
    --   { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
    -- },
  },
}
