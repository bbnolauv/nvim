return {
  "akinsho/bufferline.nvim",
  cond = false,
  event = "VeryLazy",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    options = {
      diagnostics = "nvim_lsp",

      --- count is an integer representing total count of errors
      --- level is a string "error" | "warning"
      --- diagnostics_dict is a dictionary from error level ("error", "warning" or "info")to number of errors for each level.
      --- this should return a string
      --- Don't get too fancy as this function will be executed a lot
      diagnostics_indicator = function(count, level, diagnostics_dict, context)
        local icon = level:match("error") and " " or " "
        return " " .. icon .. count
      end,
    },
  },
}
