---@type LazyPluginSpec
return {
  "tpope/vim-fugitive",
  cmd = { "G", "Git", "Gdiffsplit", "Gread", "Gwrite", "Gclog" },
  keys = { { "<leader>n", "<cmd>G<cr>", desc = "Open fugitive" } },
}
