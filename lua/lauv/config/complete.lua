local limitStr = function(str)
    if #str > 25 then
        str = string.sub(str, 1, 22) .. "..."
    end
    return str
end

return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "neovim/nvim-lspconfig",
        "hrsh7th/cmp-calc",
        "onsails/lspkind.nvim",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        -- "SirVer/ultisnips",
        -- "quangnguyen30192/cmp-nvim-ultisnips",
    },
    config = function()
        local cmp = require("cmp")
        local lspkind = require("lspkind")

        cmp.setup({
            snippet = {
                -- REQUIRED - you must specify a snippet engine
                expand = function(args)
                    require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
                    -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
                end,
            },
            window = {
                -- completion = cmp.config.window.bordered(),
                -- documentation = cmp.config.window.bordered(),
            },
            mapping = cmp.mapping.preset.insert({
                -- previous
                ["<S-Tab>"] = cmp.mapping.select_prev_item(),
                -- next
                ["<Tab>"] = cmp.mapping.select_next_item(),
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.abort(),
                -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                ["<CR>"] = cmp.mapping.confirm({
                    -- select = true,
                    select = false,
                    behavior = cmp.ConfirmBehavior.Replace,
                }),
            }),
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "buffer" },
                { name = "path" },
                { name = "calc" },
                { name = "luasnip" }, -- For luasnip users.
                -- { name = "ultisnips" }, -- For ultisnips users.
            }),
            formatting = {
                fields = { "kind", "abbr", "menu" },
                maxwidth = 60,
                maxheight = 10,
                format = function(entry, vim_item)
                    local kind = lspkind.cmp_format({
                        mode = "symbol_text",
                        symbol_map = { Codeium = "" },
                    })(entry, vim_item)
                    local strings = vim.split(kind.kind, "%s", { trimempty = true })
                    kind.kind = " " .. (strings[1] or "") .. " "
                    kind.menu = limitStr(entry:get_completion_item().detail or "")

                    return kind
                end,
            },
            -- formatting = {
            --     format = lspkind.cmp_format({
            --         with_text = false, -- do not show text alongside icons
            --         maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
            --         -- before = function (entry, vim_item)
            --         --     -- Source 显示提示来源
            --         --     vim_item.menu = "["..string.upper(entry.source.name).."]"
            --         --     return vim_item
            --         -- end,
            --     }),
            -- },
        })

        -- Set configuration for specific filetype.
        cmp.setup.filetype("gitcommit", {
            sources = cmp.config.sources({
                { name = "git" }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
            }, {
                { name = "buffer" },
            }),
        })

        -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline({ "/", "?" }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = "buffer" },
            },
        })

        -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = "path" },
            }, {
                { name = "cmdline" },
            }),
        })

        -- Set up lspconfig.
        local capabilities = require("cmp_nvim_lsp").default_capabilities()
        -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
        -- require("lspconfig")[].setup({
        -- 	capabilities = capabilities,
        -- })
        local server = {
            "pyright",
            "clangd",
            "cmake",
            "lua_ls",
        }
        for _, lsp in pairs(server) do
            require("lspconfig")[lsp].setup({
                capabilities = capabilities,
            })
        end
    end,
}
