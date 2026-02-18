return {
  "ibhagwan/fzf-lua",
  -- optional for icon support
  -- dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = "FzfLua",
  -- stylua: ignore start
  keys = {
    { "<leader>u", function() FzfLua.files() end,     desc = "FzfLua files", },
    { "<leader>o", function() FzfLua.oldfiles() end,  desc = "FzfLua oldfiles", },
    { "<leader>k", function() FzfLua.live_grep() end, desc = "FzfLua live_grep", },
    { "<leader>l", function() FzfLua.buffers() end,   desc = "FzfLua buffers", },
    { "<leader>m", function() FzfLua.marks() end,     desc = "FzfLua marks", },
    { "<leader>f", ":FzfLua ",                        desc = "Populate command line with ':FzfLua '" },
    {
      "<leader>i",
      function()
        FzfLua.lsp_document_symbols({
          regex_filter = function(item, _)
            local kind = item.kind
            return kind == "Struct" or kind == "Enum" or kind == "Method" or kind == "Function"
          end,
        })
      end,
      desc = "FzfLua lsp_document_symbols",
    },
  },
  -- stylua: ignore end

  ---@module "fzf-lua"
  ---@type fzf-lua.Config
  opts = {
    fzf_colors = {
      true,
    },
  },
}
