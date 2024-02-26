return {
    {
        'iamcco/markdown-preview.nvim',
        ft = { "markdown" },
        build = "cd app && yarn install",
        config = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
    },
    {
        'ekickx/clipboard-image.nvim',
        ft = { "markdown" },
        config = function ()
        end,
    },
    {
        'lilydjwg/fcitx.vim'
    }
}
