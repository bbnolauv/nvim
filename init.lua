-- Check if running in Neovim
if vim.fn.has("nvim") == 1 then
  -- Require the 'lauv' module
  require("lauv")
else
  -- Print error message
  vim.api.nvim_err_writeln("Neovim hasn't been installed!!!")
end

-- Check if the '.local_vimrc' file is readable
if vim.fn.filereadable(".local_vimrc") == 1 then
  -- Source the '.local_vimrc' file
  vim.cmd("source .local_vimrc")
end
