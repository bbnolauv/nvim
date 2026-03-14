return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false, -- Does not support lazy-loading
  build = ":TSUpdate",
  config = function()
    local nvim_ts = require("nvim-treesitter")

    local ensure_installed = {
      "bash",
      "c",
      "cmake",
      "cpp",
      "diff",
      "gitcommit",
      "json",
      "lua",
      "markdown",
      "markdown_inline",
      "python",
      "vim",
      "vimdoc",
    }
    nvim_ts.install(ensure_installed)

    vim.api.nvim_create_autocmd("FileType", {
      pattern = ensure_installed,
      desc = "Enable treesitter-based features for supported filetypes",
      callback = function(args)
        local ft = vim.bo[args.buf].filetype
        local lang = vim.treesitter.language.get_lang(ft)
        if not lang then
          return
        end

        if not vim.treesitter.language.add(lang) then
          local available = vim.g.ts_available or nvim_ts.get_available()
          if not vim.g.ts_available then
            vim.g.ts_available = available
          end
          if vim.tbl_contains(available, lang) then
            nvim_ts.install(lang)
          end
        end

        if vim.treesitter.language.add(lang) then
          -- Syntax highlighting
          vim.treesitter.start()
          -- Folds
          vim.wo.foldmethod = "expr"
          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          -- Indentation
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
