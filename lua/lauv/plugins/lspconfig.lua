return {
  {
    "neovim/nvim-lspconfig",
    ft = { "c", "cpp", "python", "lua" },
    dependencies = {
      { "nvimdev/lspsaga.nvim", opts = { symbol_in_winbar = { enable = false } } },
    },
    config = function()
      local lspconfig = require("lspconfig")

      -- Configure clangd LSP
      lspconfig.clangd.setup({
        cmd = { "clangd" },
        filetypes = { "c", "cpp", "objc", "objcpp" },
        root_dir = function(fname)
          return lspconfig.util.root_pattern(
            ".clangd",
            ".clang-tidy",
            ".clang-format",
            "compile_commands.json",
            "compile_flags.txt",
            "CMakeLists.txt"
          )(fname) or lspconfig.util.find_git_ancestor(fname)
        end,
        on_attach = function(client, bufnr)
          local m_root_dir = client.config.root_dir

          if vim.fn.isdirectory(m_root_dir) == 0 then
            vim.notify("[LSP] Unable to locate project root directory", vim.log.levels.INFO)
            return
          end

          -- Replace the command originally mapped to <F5> from runner.lua with the command from cmake-tools.lua.
          vim.keymap.set("n", "<F5>", "<cmd>CMakeRun<cr>", { silent = true })

          local path = require("plenary.path")
          local CONFIG = {
            cache_timeout = 600,
            cmake_build_dir = "build",
          }

          -- Check if compile_commands.json needs to be generated
          local function should_generate_commands(root_dir)
            -- Get possible paths for compile_commands.json
            local candidates = {
              path:new(root_dir, CONFIG.cmake_build_dir, "compile_commands.json").filename,
              path:new(root_dir, "compile_commands.json").filename,
            }
            -- Check for valid paths
            for _, filepath in ipairs(candidates) do
              local file_stat = vim.uv.fs_stat(filepath)
              if file_stat then
                -- Check file freshness
                return (os.time() - file_stat.mtime.sec) > CONFIG.cache_timeout
              end
            end
            return true
          end

          -- Core logic to generate compile_commands.json
          local function generate_compile_commands(root_dir)
            if vim.fn.executable("cmake") == 1 and path:new(root_dir, "CMakeLists.txt"):exists() then
              require("cmake-tools").generate({}, function(result)
                if result:is_ok() then
                  vim.notify("[LSP] CMake successfully generated the compilation database", vim.log.levels.INFO)
                  vim.schedule(function()
                    vim.cmd("LspRestart clangd") -- Restart LSP asynchronously
                  end)
                else
                  vim.notify("[LSP] CMake generation failed", vim.log.levels.ERROR)
                end
              end)
            else
              vim.notify("[LSP] CMake not found, unable to generate the compilation database", vim.log.levels.WARN)
            end
          end

          if should_generate_commands(m_root_dir) then
            vim.schedule(function()
              generate_compile_commands(m_root_dir)
            end)
          end
        end,
        capabilities = {},
      })

      lspconfig.lua_ls.setup({})
      lspconfig.pyright.setup({})

      -- Disable lsp log
      vim.lsp.set_log_level("off")

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

          vim.keymap.set("n", "<space>ca", "<cmd>Lspsaga code_action<cr>", opts)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gR", "<cmd>Lspsaga rename<cr>", opts)
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
