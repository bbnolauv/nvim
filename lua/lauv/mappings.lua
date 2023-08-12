-- use space as a the leader key
vim.g.mapleader = ' '
--vim.g.mapleader = "\<space>"

-- Functional wrapper for mapping custom keybindings
local function map(mode, lhs, rhs, opts)
    if type(mode) == "table" then
        for i = 1, #mode do
            map(mode[i], lhs, rhs, opts)
        end
        return
    end
    local options = { noremap = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

map("i", "kj", "<Esc>", { silent = true })
map("n", "Z", "ZZ", { silent = true })
map({ "v", "n" }, "gh", "(v:count == 0 || v:count == 1 ? '^^' : '^^' . (v:count - 1) . 'l')",
    { silent = true, expr = true })
map({ "v", "n" }, "gl", "(v:count == 0 || v:count == 1 ? '^$' : '^$' . (v:count - 1) . 'h')",
    { silent = true, expr = true })
map({ "v", "n", "i" }, "<F4>", "<cmd>wa<CR>")
--map('n', "<F1>", "<cmd>wa<CR><cmd>b#<CR>", { silent = true })
map({ "n", "i", "v" }, "<F1>", "<ESC><cmd>wa<CR><cmd>b#<CR>", { silent = true })
map({ "n", "i", "v" }, "<F2>", "<ESC><cmd>wa<CR><cmd>bp<CR>", { silent = true })
map({ "n", "i", "v" }, "<F3>", "<ESC><cmd>wa<CR><cmd>bn<CR>", { silent = true })
map({ "n" }, "<Esc>", [[<Cmd>nohls<CR><Esc>]], { noremap = true })

-- windows movement
map({ "v", "n", "i", "t" }, "<C-h>", [[<C-w>h]])
map({ "v", "n", "i", "t" }, "<C-j>", [[<C-w>j]])
map({ "v", "n", "i", "t" }, "<C-k>", [[<C-w>k]])
map({ "v", "n", "i", "t" }, "<C-l>", [[<C-w>l]])

-- Telescope
map("n", "<leader>u", "<cmd>Telescope find_files initial_mode=insert<CR>")
-- 查找 git 仓库中的文件
map("n", "<leader>i", "<cmd>Telescope git_files initial_mode=insert<CR>")
-- 查找最近打开过的文件
map("n", "<leader>o", "<cmd>Telescope oldfiles<CR>")
-- 查找 git status 中的文件
map("n", "<leader>p", "<cmd>Telescope git_status<CR>")
-- 查找当前项目文件中的文字
map("n", "<leader>k", "<cmd>Telescope live_grep initial_mode=insert<CR>")
-- 查找所有已打开文件
map("n", "<leader>l", "<cmd>Telescope buffers<CR>")

-- -- Neoformat
-- map("n", "<leader>q", "<cmd>Neoformat<CR>", { silent = true })

-- Trouble
map("n", "<leader>t", "<cmd>TroubleToggle<CR>", { silent = true })

-- Color Preview
map("n", "<leader>cl", '<cmd>HexokinaseToggle<CR>')

-- Copilot
map('n', '<leader>go', ':Copilot<CR>', { silent = true })
map('n', '<leader>ge', ':Copilot enable<CR>', { silent = true })
map('n', '<leader>gd', ':Copilot disable<CR>', { silent = true })
vim.cmd('imap <silent><script><expr> <C-C> copilot#Accept("")')

-- Undotree
map('n', '<F7>', '<cmd>UndotreeToggle<CR>', { silent = true })

