return {
    "akinsho/toggleterm.nvim",
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
            open_mapping = [[<F8>]],
            hide_numbers = true, -- hide the number column in toggleterm buffers
            shade_filetypes = {},
            shade_terminals = false,
            shading_factor = "-10", -- the percentage by which to lighten terminal background, default: -30 (gets multiplied by -3 if background is light)
            start_in_insert = true,
            insert_mappings = true, -- whether or not the open mapping applies in insert mode
            terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
            persist_size = true,
            -- direction = 'horizontal',
            direction = "vertical",
            close_on_exit = true, -- close the terminal window when the process exits
            -- This field is only relevant if direction is set to 'float'
            float_opts = {
                -- The border key is *almost* the same as 'nvim_open_win'
                -- see :h nvim_open_win for details on borders however
                -- the 'curved' border is a custom border type
                -- not natively supported but implemented in this plugin.
                border = "curved",
                width = 80,
                height = 25,
                winblend = 3,
            },
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
            -- vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
            vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
            vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
            vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
            vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
        end

        -- if you only want these mappings for toggle term use term://*toggleterm#* instead
        vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
    end,
}
