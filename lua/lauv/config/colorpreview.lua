return {
  "rrethy/vim-hexokinase",
  build = "make hexokinase",
  cmd = "HexokinaseToggle",
  pin = true,
  config = function()
    vim.g.Hexokinase_highlighters = { "virtual" }
  end,
}
