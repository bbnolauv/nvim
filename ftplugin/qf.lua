-- Avoid opening other buffers in the quickfix window.
vim.wo.winfixbuf = true

vim.keymap.set("n", "q", "<Cmd>close<CR>", { desc = "Close Quickfix", nowait = true, buffer = true })
