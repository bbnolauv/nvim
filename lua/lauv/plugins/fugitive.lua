---@type LazyPluginSpec
return {
  "bbnolauv/vim-fugitive",
  cmd = { "G", "Git", "Gdiffsplit", "Gread", "Gwrite", "Gclog" },
  keys = { { "<leader>n", "<cmd>tab Git<cr>", desc = "Open fugitive" } },
}
