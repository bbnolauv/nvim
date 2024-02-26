vim.cmd [[
" press <Tab> to expand or jump in a snippet. These can also be mapped separately
" via <Plug>luasnip-expand-snippet and <Plug>luasnip-jump-next.
imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>' 
" -1 for jumping backwards.
inoremap <silent> <S-Tab> <cmd>lua require'luasnip'.jump(-1)<Cr>

snoremap <silent> <Tab> <cmd>lua require('luasnip').jump(1)<Cr>
snoremap <silent> <S-Tab> <cmd>lua require('luasnip').jump(-1)<Cr>

"" For changing choices in choiceNodes (not strictly necessary for a basic setup).
"imap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
"smap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
]]
return {
    "L3MON4D3/LuaSnip",
    lazy = true,
    dependencies = {
        'rafamadriz/friendly-snippets',
    },
    config = function()
        vim.opt.rtp = vim.opt.rtp + '~/.local/share/nvim/lazy/friendly-snippets'
        require('luasnip.loaders.from_vscode').lazy_load()
        local luasnip = require('luasnip')
        -- Stop snippets when you leave to normal mode
        vim.api.nvim_create_autocmd('ModeChanged', {
            callback = function()
                if ((vim.v.event.old_mode == 's' and vim.v.event.new_mode == 'n') or vim.v.event.old_mode == 'i')
                    and luasnip.session.current_nodes[vim.api.nvim_get_current_buf()]
                    and not luasnip.session.jump_active
                then
                    luasnip.unlink_current()
                end
            end
        })
    end
}
