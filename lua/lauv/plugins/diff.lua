return {
  -- Lazy
  {
    'dlyongemallo/diffview-plus.nvim',
    version = '*',
    -- optional: lazy-load on command
    cmd = {
      'DiffviewOpen',
      'DiffviewToggle',
      'DiffviewFileHistory',
      'DiffviewDiffFiles',
      'DiffviewLog',
    },
  },
  {
    'barrettruth/diffs.nvim',
    config = function()
      vim.g.diffs = {
        integrations = {
          fugitive = true,
          gitsigns = true,
        },
      }
    end,
  },
}
