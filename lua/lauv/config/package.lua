local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local result = vim.system({
    'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath,
  }):wait()
  if result.code ~= 0 then
    local out = vim.trim(result.stderr .. result.stdout)
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  spec = {
    { import = 'lauv.plugins.lib' },
    { import = 'lauv.plugins.treesitter' },
    { import = 'lauv.plugins' },
  },
  change_detection = { notify = false },
  ui = { border = 'rounded' },
  dev = {
    path = '~/Downloads/repo/lazy_plugins',
    -- patterns = { 'bbnolauv' },
    fallback = false, -- Fallback to git when local plugin doesn't exist
  },
  --- @diagnostic disable-next-line: missing-parameter
})
