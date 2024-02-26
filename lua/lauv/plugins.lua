local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- To-Do:
-- lsp-zero
-- notify           >       notification

-- Done:
-- treesitter       >       syntax          *
-- telescope        >       fuzzy search    *
-- nvim-comment     >       comment         *
-- lsp
-- format
-- surround
-- undotree

require("lazy").setup({
    require("lauv.config.colorscheme"),
    require("lauv.config.tab"),
    require("lauv.config.status"),
    require("lauv.config.treesitter"), -- syntax highlight
    require("lauv.config.telescope"),  -- fuzzy search
    require("lauv.config.mason"),      -- lsp server manager
    require("lauv.config.complete"),
    require("lauv.config.lspconfig"),
    require("lauv.config.comment"),
    require("lauv.config.format"),
    require("lauv.config.terminal"),
    require("lauv.config.colorpreview"),
    require("lauv.config.surround"),
    require("lauv.config.markdown"),
    -- require("lauv.config.typst"),
    -- require("lauv.config.filetype"),
    require("lauv.config.copilot"),
    -- require("lauv.config.undotree"),
    require("lauv.config.snippets"),
    require("lauv.config.autopairs"),
})

require("lauv.utils.runner")
