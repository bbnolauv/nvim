return {
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000,
  opts = {
    transparent_background = true,
    -- float = {
    --   transparent = true,
    -- },
  },
  config = function(_, opts)
    require('catppuccin').setup(opts)
    vim.cmd.colorscheme('catppuccin-nvim')
    -- vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#878787" })
    -- vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "#276f70", italic = true })
  end,
}
