-- 'bigfile' filetype: disable heavy features that make very large or minified
-- files slow to edit. Sourced automatically when filetype.lua detects one.
-- Ported from folke/snacks.nvim's bigfile.lua.

local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':p:~:.')
vim.notify(
  ('Big file detected `%s`.\nSome Neovim features have been **disabled**.'):format(path),
  vim.log.levels.WARN,
  { title = 'Big File' }
)

if vim.fn.exists(':NoMatchParen') ~= 0 then
  vim.cmd('NoMatchParen')
end

vim.wo.foldmethod = 'manual'
vim.wo.statuscolumn = ''
vim.wo.conceallevel = 0

vim.b.completion = false
vim.b.minianimate_disable = true
vim.b.minihipatterns_disable = true

-- Restore the underlying filetype's syntax (e.g. JSON for minified files),
-- since the buffer's filetype is now 'bigfile'.
local buf = vim.api.nvim_get_current_buf()
vim.schedule(function()
  if vim.api.nvim_buf_is_valid(buf) then
    vim.bo[buf].syntax = vim.filetype.match({ buf = buf }) or ''
  end
end)
