---@type LazyPluginSpec
return {
  'bbnolauv/vim-fugitive',
  -- Tip: 'Gclog' doesn't work very well with lazy.nvim's on-command lazy loading.
  -- Consider using 'FzfLua git_bcommits' instead.
  -- Tip2: 'Gclog' seems ok?
  cmd = { 'G', 'Git', 'Gclog', 'Gdiffsplit' },
  keys = { { '<leader>n', '<cmd>tab Git<cr>', desc = 'Open fugitive' } },
}
