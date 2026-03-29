-- Avoid opening other buffers in the quickfix window.
vim.wo.winfixbuf = true

vim.keymap.set(
  'n',
  'q',
  '<Cmd>close<CR>',
  { desc = 'Close Quickfix', nowait = true, buffer = true }
)
vim.keymap.set(
  'n',
  'R',
  ':cdo s/<c-r>"//gc<Left><Left><Left>',
  { desc = 'Run substitute for each entry', buffer = true }
)
