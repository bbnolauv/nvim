local o = vim.o
o.conceallevel = 2
o.cursorline = true
o.cursorlineopt = 'number'
o.expandtab = true
o.fillchars = 'eob: ,diff:╱,foldopen:,foldclose:,foldsep:▕,foldinner:▕,'
o.foldcolumn = 'auto'
o.foldenable = true
o.foldlevelstart = 99
o.laststatus = 3
o.list = true
o.listchars = 'tab:» ,nbsp:+,trail:·,extends:→,precedes:←,leadmultispace:| ,'
o.mouse = 'a'
o.number = true
o.pumborder = 'rounded'
o.relativenumber = true
o.scrolloff = 4
o.shiftwidth = 2
o.shortmess = 'aItToOCF'
o.showbreak = '↪'
-- o.showcmdloc = 'statusline'
o.showmode = false
o.sidescrolloff = 4
o.signcolumn = 'yes'
o.smoothscroll = true
o.softtabstop = 0
o.switchbuf = 'useopen,usetab,uselast'
o.tabstop = 2
-- o.undofile = true
o.winborder = 'rounded'

-- check link `https://www.cnblogs.com/sxrhhh/p/18234652/neovim-copy-anywhere`
if os.getenv('SSH_TTY') == nil then
  --Current env is local, include WSL
  o.clipboard = 'unnamedplus'
else
  -- Issue of windows terminal, check link below:
  -- https://github.com/microsoft/terminal/issues/17735
  vim.g.clipboard = {
    name = 'OSC 52',
    copy = {
      ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
      ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
    },
    paste = {
      ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
      ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
    },
  }
end
local function augroup(name)
  return vim.api.nvim_create_augroup('lauvvim_' .. name, { clear = true })
end

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  group = augroup('checktime'),
  callback = function()
    if o.buftype ~= 'nofile' then
      vim.cmd('checktime')
    end
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup('highlight_yank'),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ 'VimResized' }, {
  group = augroup('resize_splits'),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd('tabdo wincmd =')
    vim.cmd('tabnext ' .. current_tab)
  end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd('BufReadPost', {
  group = augroup('last_loc'),
  callback = function(event)
    local exclude = { 'gitcommit' }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  group = augroup('auto_create_dir'),
  callback = function(event)
    if event.match:match('^%w%w+:[\\/][\\/]') then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})

-- -- don't extend the stupid comments:
-- vim.api.nvim_create_autocmd('BufEnter', {
--   group = augroup('disable_formatoptions_cro'),
--   pattern = '*',
--   callback = function()
--     vim.opt.formatoptions:remove({ 'c', 'r', 'o' })
--   end,
-- })

-- -- smart number
-- vim.api.nvim_create_autocmd('InsertEnter', {
--   group = augroup('smart_number1'),
--   callback = function()
--     vim.wo.relativenumber = false
--   end,
-- })
-- vim.api.nvim_create_autocmd('InsertLeave', {
--   group = augroup('smart_number2'),
--   callback = function()
--     vim.wo.relativenumber = true
--   end,
-- })
