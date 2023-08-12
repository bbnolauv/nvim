return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    priority = 1000,
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed = { "c", "cpp", "python", "cmake", "lua", "vim", "bash", "markdown", "json" }, -- INFO: add your language here
            highlight = {
                enable = true,
                disable = {}, -- list of language that will be disabled
            },
            indent = {
                enable = false
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection    = "<CR>",
                    node_incremental  = "<CR>",
                    node_decremental  = "<BS>",
                    scope_incremental = "<TAB>",
                },
            }
        })
    end
}
