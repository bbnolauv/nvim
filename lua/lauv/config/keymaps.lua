-- use space as the leader key
vim.g.mapleader = ' '

if vim.fn.has('nvim-0.11') == 1 then
  vim.keymap.del('n', 'gri')
  vim.keymap.del('n', 'gra')
  vim.keymap.del('n', 'grn')
  vim.keymap.del('n', 'grr')
  vim.keymap.del('n', 'grt')
end

-- Emacs style cmdline
vim.keymap.set('c', '<C-p>', '<Up>')
vim.keymap.set('c', '<C-n>', '<Down>')
vim.keymap.set('c', '<C-b>', '<Left>')
vim.keymap.set('c', '<C-f>', '<Right>')
vim.keymap.set('c', '<C-a>', '<Home>')
vim.keymap.set('c', '<C-e>', '<End>')
vim.keymap.set('c', '<C-d>', '<Del>')
-- Move one word left/right
vim.keymap.set('c', '<M-b>', '<S-Left>')
vim.keymap.set('c', '<M-f>', '<S-Right>')

vim.keymap.set({ 'n', 'x' }, '<Leader>', '<Nop>')

vim.keymap.set('x', 'x', '"_d', { desc = 'use blackhole register for non-copy' }) -- for copy and delete use v_d
vim.keymap.set('n', 'z=', function()
  vim.bo.spelllang = 'en_us,cjk'
  vim.wo.spell = true
  vim.cmd('normal! z=')
end)

-- :h c_CTRL-F
vim.o.cedit = '<C-o>'
vim.keymap.set({ 'n', 'x' }, 'q', '<Nop>')
vim.keymap.set({ 'n', 'x' }, '<leader>q', 'q')
-- vim.keymap.set('n', 'q;', 'q:')

-- Argument list
-- Reference: https://jkrl.me/vim/2025/05/28/nvim-arglist.html
vim.keymap.set('n', '<Leader>al', '<C-l><Cmd>args<CR>', { desc = 'list files in arglist' })
vim.keymap.set('n', '<Leader>ag', function()
  local count = vim.v.count
  local prefix = count > 0 and tostring(count) or ''
  return ':<C-u>' .. prefix .. 'argu|args<CR><Esc>'
end, { expr = true, desc = 'jump to the [count]th file, or the current one without [count]' })
vim.keymap.set(
  'n',
  '<Leader>aa',
  '<Cmd>$arge %<bar>argded<bar>args<CR>',
  { desc = 'add current file to arglist' }
)
vim.keymap.set(
  'n',
  '<Leader>ad',
  '<Cmd>argd %<bar>args<CR>',
  { desc = 'delete current file from arglist' }
)
vim.keymap.set(
  'n',
  '<Leader>ac',
  '<Cmd>%argd<CR><C-l>',
  { desc = 'clear arglist (i.e., delete all)' }
)

vim.keymap.set({ 'n', 'x' }, '<leader>y', '"+y', { desc = 'system clipboard support' })

vim.keymap.set(
  { 'v', 'n' },
  'gh',
  "(v:count == 0 || v:count == 1 ? '^^' : '^^' . (v:count - 1) . 'l')",
  { expr = true, desc = 'To the first [count - 1] non-blank character of the line' }
)
vim.keymap.set(
  { 'v', 'n' },
  'gl',
  "(v:count == 0 || v:count == 1 ? '^$' : '^$' . (v:count - 1) . 'h')",
  { expr = true, desc = 'To the last [count - 1] character of the line' }
)

vim.keymap.set({ 'n', 'v' }, '<F1>', '<cmd>b#<CR>', { desc = ':h alternate-file' })

-- :h CTRL-L (nohlsearch/diffupdate)
vim.keymap.set(
  'i',
  '<c-l>',
  '<Right>',
  { desc = 'Move one character right, useful to get out of pairs' }
)

-- windows movement
vim.keymap.set('n', '<Up>', '<c-w>k')
vim.keymap.set('n', '<Down>', '<c-w>j')
vim.keymap.set('n', '<Left>', '<c-w>h')
vim.keymap.set('n', '<Right>', '<c-w>l')

---@type Utils.runner
local UtilRunner = require('lauv.utils.runner')

vim.keymap.set('n', '<F5>', UtilRunner.run_single_file)
vim.keymap.set('n', '<leader>gg', UtilRunner.lazygit)

vim.api.nvim_create_user_command('Diagnostics', function(opts)
  local qf_info = vim.fn.getqflist({ title = 1, winid = 1 })

  -- Toggle action only if the quickfix window is open AND it's our diagnostics list.
  if qf_info.winid ~= 0 and qf_info.title == 'Diagnostics' then
    vim.cmd.cclose()
  else
    local bufnr = opts.bang and 0 or nil
    if #vim.diagnostic.get(bufnr) > 0 then
      vim.diagnostic.setqflist({ title = 'Diagnostics' })
    else
      vim.notify('No diagnostics found', vim.log.levels.WARN)
    end
  end
end, { bang = true, desc = 'Toggle diagnostics in quickfix list' })

vim.keymap.set('n', '<leader>t', '<cmd>Diagnostics<cr>')

-- Move the current line or selections up and down with corresponding indentation
vim.keymap.set('x', 'J', ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set('x', 'K', ":m '<-2<CR>gv=gv", { silent = true })

vim.keymap.set('n', '<Leader><C-g>', function()
  local msg = {}
  local isfile = vim.fn.empty(vim.fn.expand('%:p')) == 0
  -- Show file info
  local oldmsg = vim.trim(vim.fn.execute('norm! 2' .. vim.keycode('<C-g>')))
  local mtime = isfile and vim.fn.strftime('%Y-%m-%d %H:%M', vim.fn.getftime(vim.fn.expand('%:p')))
    or ''
  table.insert(msg, { ('%s  %s\n'):format(oldmsg:sub(1), mtime) })
  -- Show git branch
  local gitref = vim.fn.exists('*FugitiveHead') == 1 and vim.fn['FugitiveHead'](7) or nil
  if gitref then
    table.insert(msg, { ('branch: %s\n'):format(gitref) })
  end
  -- Show current directory
  table.insert(msg, { ('cwd: %s\n'):format(vim.fn.fnamemodify(vim.fn.getcwd(), ':~')) })
  -- Show current session
  table.insert(msg, {
    ('session: %s\n'):format(
      #vim.v.this_session > 0 and vim.fn.fnamemodify(vim.v.this_session, ':~') or '?'
    ),
  })
  -- Show process id
  table.insert(msg, { ('PID: %s\n'):format(vim.fn.getpid()) })
  -- Show current context
  table.insert(msg, {
    vim.fn.getline(vim.fn.search('\\v^[[:alpha:]$_]', 'bn', 1, 100)),
    'Identifier',
  })
  vim.api.nvim_echo(msg, false, {})
end, { desc = 'Enhanced Ctrl-G (borrowed from justinmk/config)' })

-- g?: Web search
vim.keymap.set('n', 'g??', function()
  vim.ui.open(('https://google.com/search?q=%s'):format(vim.fn.expand('<cword>')))
end)
vim.keymap.set('x', 'g??', function()
  local region = vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('v'), { type = vim.fn.mode() })
  vim.ui.open(('https://google.com/search?q=%s'):format(vim.trim(table.concat(region, ' '))))
  vim.api.nvim_input('<esc>')
end)
