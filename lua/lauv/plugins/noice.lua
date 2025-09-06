return {
  "folke/noice.nvim",
  event = "VeryLazy",
  -- dependencies = { "MunifTanjim/nui.nvim" },
  opts = {
    presets = {
      long_message_to_split = true, -- long messages will be sent to a split
      lsp_doc_border = true, -- add a border to hover docs and signature help
    },
  },
}
