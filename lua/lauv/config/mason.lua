return {
    "williamboman/mason-lspconfig.nvim",
    -- keys = { {"<cmd>Mason<cr>", desc = "Mason" } },
    -- lazy = true,
    dependencies = {
        { "williamboman/mason.nvim", build = ":MasonUpdate" },
    },
    config = function()
        require("mason").setup({
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
            },
        })
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "clangd",
                "pyright",
                "cmake",
            },
            automatic_installation = true,
        })
    end,
}
