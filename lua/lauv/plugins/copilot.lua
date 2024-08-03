return {
  "github/copilot.vim",
  cmd = { "Copilot" },
  config = function()
    vim.g.copilot_enabled = true
    vim.g.copilot_no_tab_map = true
    -- vim.api.nvim_set_keymap('i', '<c-p>', '<Plug>(copilot-suggest)', {})
    -- vim.api.nvim_set_keymap('i', '<c-n>', '<Plug>(copilot-next)', { silent = true })
    -- vim.api.nvim_set_keymap('i', '<c-l>', '<Plug>(copilot-previous)', { silent = true })
    vim.cmd([[
        let g:copilot_filetypes = {
         \ 'TelescopePrompt': v:false,
         \ }
        ]])
  end,
}
