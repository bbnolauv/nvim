vim.cmd [[
set mouse=a
set nu rnu ru ls=2
set et sts=0 ts=4 sw=4
set signcolumn=yes
set cinoptions=j1,(0,ws,Ws,g0
set list
set listchars=tab:▸\ ,trail:⋅,extends:❯,precedes:❮
set showbreak=↪
set clipboard+=unnamedplus
set switchbuf=useopen
]]

-- don't extend the stupid comments:
vim.cmd [[
augroup disable_formatoptions_cro
autocmd!
autocmd BufEnter * setlocal formatoptions-=cro
augroup end
]]

-- goto last location on open:
vim.cmd [[
augroup back_last_location
autocmd!
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
augroup end
]]
