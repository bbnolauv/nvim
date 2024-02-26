return {
    "nathom/filetype.nvim",
    config = function ()
        -- In init.lua or filetype.nvim's config file
        require("filetype").setup({
            overrides = {
                extensions = {
                    -- Set the filetype of *.typ files to typst
                    typ = "typst",
                },
            },
        })
    end
}
