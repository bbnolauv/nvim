vim.o.foldmethod = 'syntax'
vim.o.foldlevel = 1
vim.wo.scrolloff = 99

vim.keymap.set('n', '<Tab>', 'za', { desc = 'Toggle folding', nowait = true, buffer = true })
