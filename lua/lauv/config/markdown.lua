return {
  {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown" },
    build = "cd app && yarn install",
    config = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
  },
  {
    "Kicamon/im-switch.nvim",
    cond = false,
    ft = { "markdown" },
    opts = {
      text = { -- Documents that automatically switch input method
        "*.md",
        "*.txt",
      },
      -- code = { -- Languages that automatically switch input method for code comments
      --     "*.lua",
      --     "*.c",
      --     "*.cpp",
      --     "*.py",
      -- },
      en = "fcitx5-remote -c",
      zh = "fcitx5-remote -o",
      check = "fcitx5-remote",
    },
  },
}
