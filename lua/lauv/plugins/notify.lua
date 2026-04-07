---@type LazyPluginSpec
return {
  'rcarriga/nvim-notify',
  version = '*',
  event = 'VeryLazy',
  opts = {
    render = 'compact',
    stages = 'static',
    max_width = 60,
  },
  config = function(_, opts)
    require('notify').setup(opts)
    vim.notify = require('notify')
  end,
}
