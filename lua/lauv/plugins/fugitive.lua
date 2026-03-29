---@type LazyPluginSpec
return {
  'bbnolauv/vim-fugitive',
  -- Tip: 'Gclog' doesn't work very well with lazy.nvim's on-command lazy loading.
  -- Consider using 'FzfLua git_bcommits' instead.
  cmd = { 'G', 'Git', 'Gdiffsplit' },
  keys = { { '<leader>n', '<cmd>tab Git<cr>', desc = 'Open fugitive' } },
}
