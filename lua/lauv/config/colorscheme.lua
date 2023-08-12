return {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        vim.cmd([[
        set termguicolors
        colorscheme gruvbox
        "set guicursor=
        hi LineNrAbove guifg=#cc6666 ctermfg=red
        hi LineNrBelow guifg=#66cc66 ctermfg=green
        hi SignColumn guibg=none
        hi Normal guifg=#ebdbb2 guibg=none
        ]])
    end,
}
