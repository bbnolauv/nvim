-- use space as the leader key
vim.g.mapleader = " "

if vim.fn.has("nvim-0.11") == 1 then
  vim.keymap.del("n", "gri")
  vim.keymap.del("n", "gra")
  vim.keymap.del("n", "grn")
  vim.keymap.del("n", "grr")
  vim.keymap.del("n", "grt")
end

-- Functional wrapper for mapping custom keybindings
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- map("i", "kj", "<Esc>", { silent = true })
map("n", "Z", "ZZ", { silent = true })
map(
  { "v", "n" },
  "gh",
  "(v:count == 0 || v:count == 1 ? '^^' : '^^' . (v:count - 1) . 'l')",
  { silent = true, expr = true }
)
map(
  { "v", "n" },
  "gl",
  "(v:count == 0 || v:count == 1 ? '^$' : '^$' . (v:count - 1) . 'h')",
  { silent = true, expr = true }
)
map({ "v", "n", "i" }, "<F4>", "<cmd>wa<CR>")
map({ "n", "i", "v" }, "<F1>", "<ESC><cmd>wa<CR><cmd>b#<CR>", { silent = true })
map({ "n", "i", "v" }, "<F2>", "<ESC><cmd>wa<CR><cmd>bp<CR>", { silent = true })
map({ "n", "i", "v" }, "<F3>", "<ESC><cmd>wa<CR><cmd>bn<CR>", { silent = true })
map({ "n" }, "<Esc>", [[<Cmd>nohls<CR><Esc>]], { noremap = true })

map({ "i" }, "<c-l>", [[<Right>]])

-- windows movement
map({ "v", "n", "t" }, "<C-h>", [[<C-w>h]])
map({ "v", "n", "t" }, "<C-j>", [[<C-w>j]])
map({ "v", "n", "t" }, "<C-k>", [[<C-w>k]])
map({ "v", "n", "t" }, "<C-l>", [[<C-w>l]])

---@type Utils.runner
local UtilRunner = require("lauv.utils.runner")

map("n", "<F5>", UtilRunner.build_and_run, { silent = true })
map("n", "<F6>", UtilRunner.run, { silent = true })
map("n", "<leader>gg", UtilRunner.lazygit, { silent = true })

vim.api.nvim_create_user_command("Diagnostics", function(opts)
  local qf_info = vim.fn.getqflist({ title = 1, winid = 1 })

  -- Toggle action only if the quickfix window is open AND it's our diagnostics list.
  if qf_info.winid ~= 0 and qf_info.title == "Diagnostics" then
    vim.cmd.cclose()
  else
    local bufnr = opts.bang and 0 or nil
    if #vim.diagnostic.get(bufnr) > 0 then
      vim.diagnostic.setqflist({ title = "Diagnostics" })
    else
      vim.notify("No diagnostics found", vim.log.levels.WARN)
    end
  end
end, { bang = true, desc = "Toggle diagnostics in quickfix list" })

map("n", "<leader>t", "<cmd>Diagnostics<cr>", { silent = true })
