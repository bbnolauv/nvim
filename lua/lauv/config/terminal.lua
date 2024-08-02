return {
  "akinsho/toggleterm.nvim",
  cmd = "ToggleTerm",
  version = "*",
  config = function()
    require("toggleterm").setup({
      size = function(term)
        if term.direction == "horizontal" then
          return 10
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      direction = "vertical",
    })

    function _G.set_terminal_keymaps()
      local opts = { buffer = 0 }
      vim.keymap.set("n", "<Esc>", [[<Cmd>ToggleTerm<CR>]], opts)
      vim.keymap.set("n", "q", [[<Cmd>ToggleTerm<CR>]], opts)
      vim.keymap.set("n", "<C-c>", [[<Cmd>startinsert<CR><C-c>]], opts)
      -- vim.keymap.set("n", "<CR>", [[<Cmd>startinsert<CR>]], opts)
      -- vim.keymap.set("n", "<Up>", [[<Cmd><Up>startinsert<CR>]], opts)
      -- vim.keymap.set("n", "<Down>", [[<Cmd>startinsert<CR><Down>]], opts)
      -- vim.keymap.set("n", "<Right>", [[<Cmd>startinsert<CR><Right>]], opts)
      -- vim.keymap.set("n", "<Left>", [[<Cmd>startinsert<CR><Left>]], opts)
      vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)
      vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
      vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
      vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
      vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
    end

    -- if you only want these mappings for toggle term use term://*toggleterm#* instead
    vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
  end,
}
