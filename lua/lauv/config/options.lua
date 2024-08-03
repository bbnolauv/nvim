local option_table = {
  cinoptions = "j1,(0,ws,Ws,g0",
  expandtab = true,
  laststatus = 2,
  list = true,
  listchars = {
    extends = "❯",
    leadmultispace = "| ",
    precedes = "❮",
    tab = "▸ ",
    trail = "⋅",
  },
  mouse = "a",
  number = true,
  relativenumber = true,
  scrolloff = 4,
  shiftwidth = 2,
  showbreak = "↪",
  showmode = false,
  signcolumn = "yes",
  softtabstop = 0,
  switchbuf = "useopen",
  tabstop = 2,
}

for k, v in pairs(option_table) do
  vim.opt[k] = v
end

vim.opt.clipboard:append("unnamedplus")

if vim.fn.has("nvim-0.10") == 1 then
  vim.opt.smoothscroll = true
end

local function augroup(name)
  return vim.api.nvim_create_augroup("lauvvim_" .. name, { clear = true })
end

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
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
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- don't extend the stupid comments:
vim.api.nvim_create_autocmd("BufEnter", {
  group = augroup("disable_formatoptions_cro"),
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove("c")
    vim.opt_local.formatoptions:remove("r")
    vim.opt_local.formatoptions:remove("o")
  end,
})
-- vim.cmd [[
-- augroup disable_formatoptions_cro
-- autocmd!
-- autocmd BufEnter * setlocal formatoptions-=cro
-- augroup end
-- ]]
