vim.loader.enable()
require("lauv")

-- Check if the '.local_vimrc' file is readable
if vim.fn.filereadable(".local_vimrc") == 1 then
  -- Source the '.local_vimrc' file
  vim.cmd("source .local_vimrc")
end
