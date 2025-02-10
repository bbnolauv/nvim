-- use space as a the leader key
vim.g.mapleader = " "

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
map({ "n" }, "<leader><F1>", "<Cmd>vsplit ~/.config/nvim/lua/lauv/init.lua<CR>", { noremap = true })

map({ "i" }, "<c-l>", [[<Right>]])

-- windows movement
map({ "v", "n", "t" }, "<C-h>", [[<C-w>h]])
map({ "v", "n", "t" }, "<C-j>", [[<C-w>j]])
map({ "v", "n", "t" }, "<C-k>", [[<C-w>k]])
map({ "v", "n", "t" }, "<C-l>", [[<C-w>l]])

-- fzf-lua
map("n", "<leader>u", "<cmd>FzfLua files<cr>")
map("n", "<leader>o", "<cmd>FzfLua oldfiles<cr>")
map("n", "<leader>i", "<cmd>FzfLua git_files<cr>")
map("n", "<leader>p", "<cmd>FzfLua git_status<cr>")
map("n", "<leader>k", "<cmd>FzfLua live_grep<cr>")
map("n", "<leader>l", "<cmd>FzfLua buffers<cr>")
map("n", "<leader>m", "<cmd>FzfLua marks<CR>")
map("n", "<leader>f", function()
  require("fzf-lua").lsp_document_symbols({
    regex_filter = function(item, _)
      local kind = item.kind
      return kind == "Struct" or kind == "Enum" or kind == "Method" or kind == "Function"
    end,
  })
end)

-- Trouble
map("n", "<leader>t", "<cmd>Trouble diagnostics toggle focus=true<cr>", { silent = true })

-- Term
map("n", "<F8>", "<cmd>ToggleTerm<CR>", { silent = true })

-- Color Preview
map("n", "<leader>cl", "<cmd>HexokinaseToggle<CR>")

-- Copilot
map("n", "<leader>go", ":Copilot<CR>", { silent = true })

-- Undotree (doesnt work)
-- map('n', '<F7>', '<cmd>UndotreeToggle<CR>', { silent = true })

-- ImagePaste (Unavilable)
-- map({ "n", "i", "v" }, "<leader>vv", "<cmd>PasteImg<cr>", { silent = true })
