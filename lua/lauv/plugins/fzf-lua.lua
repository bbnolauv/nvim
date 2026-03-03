return {
  "ibhagwan/fzf-lua",
  -- optional for icon support
  -- dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = "FzfLua",
  -- stylua: ignore start
  keys = {
    { "<leader>fb", function() FzfLua.buffers() end,              desc = "FzfLua buffers", },
    { "<leader>ff", function() FzfLua.files() end,                desc = "FzfLua files", },
    { "<leader>fg", function() FzfLua.live_grep_native() end,     desc = "FzfLua grep", },
    { "<leader>fh", function() FzfLua.help_tags() end,            desc = "FzfLua help_tags", },
    { "<leader>fm", function() FzfLua.marks() end,                desc = "FzfLua marks", },
    { "<leader>fo", function() FzfLua.oldfiles() end,             desc = "FzfLua oldfiles", },
    { "<leader>fr", function() FzfLua.resume() end,               desc = "FzfLua resume", },
    { "<leader>fs", function() FzfLua.lsp_document_symbols() end, desc = "FzfLua lsp_document_symbols", },
    { "<leader>fz", function() FzfLua.zoxide() end,               desc = "FzfLua zoxide", },

    { "<leader>f/", function() FzfLua.search_history() end,       desc = "FzfLua search_history", },
    { "<leader>f:", function() FzfLua.command_history() end,      desc = "FzfLua command_history", },

    { "<leader>fl", ":FzfLua ",                                   desc = "Populate command line with ':FzfLua '" },
  },
  -- stylua: ignore end

  ---@module "fzf-lua"
  ---@type fzf-lua.Config
  opts = {
    fzf_colors = {
      true,
    },
    ui_select = true,
  },
}
