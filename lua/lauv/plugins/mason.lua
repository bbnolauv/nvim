--- @type LazyPluginSpec
return {
  'mason-org/mason.nvim',
  cmd = 'Mason',
  opts = {
    ui = {
      icons = {
        package_installed = '✓',
        package_pending = '➜',
        package_uninstalled = '✗',
      },
    },
    PATH = 'skip',
  },
  init = function()
    local mason_bin = vim.fs.joinpath(vim.fn.stdpath('data'), 'mason', 'bin')

    if not vim.env.PATH:find(mason_bin, 1, true) then
      local sep = vim.fn.has('win32') == 1 and ';' or ':'
      vim.env.PATH = mason_bin .. sep .. vim.env.PATH
    end
  end,
}
