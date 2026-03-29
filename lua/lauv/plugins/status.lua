-- stylua: ignore start
local colors = {
  none         = "NONE",
  black        = "#080705",
  white        = "#FFFFFA",
  red          = '#ec5f67',
  green        = "#37b97e",
  blue         = "#28C2FF",
  yellow       = "#EEE82C",
  orange       = "#FF8800",
  marble       = "#d1ccc7",
  gray         = "#595959",
  darkgray     = "#2b2b2b",
  lightgray    = "#8f8f8f",
  inactivegray = "#7c6f64",
  bg           = "NONE",
  fg           = '#abb2bf',
}
-- stylua: ignore end

local custom_theme = {
  normal = {
    a = { fg = colors.black, bg = colors.blue, gui = 'bold' },
    b = { fg = colors.marble, bg = colors.gray },
    c = { fg = colors.fg, bg = colors.bg },
  },
  command = { a = { fg = colors.black, bg = colors.red, gui = 'bold' } },
  insert = { a = { fg = colors.black, bg = colors.green, gui = 'bold' } },
  visual = { a = { fg = colors.black, bg = colors.orange, gui = 'bold' } },
  terminal = { a = { fg = colors.black, bg = colors.red, gui = 'bold' } },
  replace = { a = { fg = colors.black, bg = colors.red, gui = 'bold' } },
  inactive = {
    a = { fg = colors.darkgray, bg = colors.bg, gui = 'bold' },
    b = { fg = colors.darkgray, bg = colors.bg },
    c = { fg = colors.darkgray, bg = colors.gray },
  },
}

return {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',
  opts = {
    options = {
      theme = custom_theme,
    },
    sections = {
      lualine_a = {
        {
          'mode',
          icon = '',
          separator = { left = '', right = '' },
        },
      },
      lualine_b = {
        { 'branch', icon = '' },
        'diff',
        'diagnostics',
      },

      lualine_x = { 'lsp_status', 'filetype' },
      lualine_z = { { 'location', separator = { left = '', right = '' } } },
    },
  },
}
