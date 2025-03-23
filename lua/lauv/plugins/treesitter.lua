return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPost", "BufNewFile" },
  build = ":TSUpdate",
  main = "nvim-treesitter.configs",
  opts = {
    ensure_installed = {
      "bash",
      "c",
      "cmake",
      "cpp",
      "json",
      "lua",
      "markdown",
      "markdown_inline",
      "python",
      "vim",
      "vimdoc",
    }, -- INFO: add your language here
    highlight = {
      enable = true,
      disable = {}, -- list of language that will be disabled
    },
    indent = {
      enable = false,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<CR>",
        node_incremental = "<CR>",
        node_decremental = "<BS>",
        scope_incremental = "<TAB>",
      },
    },
  },
}
