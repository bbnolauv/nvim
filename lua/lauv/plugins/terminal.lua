return {
  "akinsho/toggleterm.nvim",
  cmd = "ToggleTerm",
  version = "*",
  opts = {
    size = function(term)
      if term.direction == "horizontal" then
        return 10
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.4
      end
    end,
    direction = "vertical",
  },
}
