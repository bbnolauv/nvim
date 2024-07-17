return {
  "ellisonleao/gruvbox.nvim",
  priority = 1000,
  opts = {
    termguicolors = true,
    guicursor = "n-v-c-sm:block,i-ci-ve:ver25-Cursor,r-cr-o:hor20",
    overrides = {
      -- For relative number
      -- LineNrAbove = { fg = "#cc6666", ctermfg = "red" },
      -- LineNrBelow = { fg = "#66cc66", ctermfg = "green" },
      SignColumn = { bg = "none" },
      Normal = { fg = "#ebdbb2", bg = "none" },
    },
  },
  init = function()
    vim.cmd.colorscheme("gruvbox")
  end,
}
