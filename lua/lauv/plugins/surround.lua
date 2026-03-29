return {
  'kylechui/nvim-surround',
  version = '^3.0.0', -- Use for stability; omit to use `main` branch for the latest features
  keys = {
    { 'gs', mode = { 'n', 'x' }, desc = 'Edit surround textobject' },
    { 'gS', mode = { 'n', 'x' }, desc = 'Edit surround line' },
  },
  opts = {
    keymaps = {
      insert = false,
      insert_line = false,
      normal = 'gs',
      normal_line = 'gS',
      normal_cur = 'gss',
      normal_cur_line = 'gSS',
      visual = 'gs',
      visual_line = 'gS',
      delete = 'gsd',
      change = 'gsc',
    },
  },
}
