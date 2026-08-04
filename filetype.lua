-- Big files use 'bigfile' filetype when either the file size or average line length exceeds the
-- threshold below. This keeps builtin syntax highlighting but disables heavier features such as LSP
-- and Treesitter.
vim.g.bigfile_size_threshold = 1024 * 1024 * 1.5 -- 1.5 MB
vim.g.bigfile_line_length_threshold = 1000

vim.filetype.add({
  pattern = {
    -- Borrowed from folke/snacks.nvim. Set filetype to bigfile in order to disable some
    -- features due to performance issues.
    ['.*'] = function(path, bufnr)
      if not path or not bufnr or vim.bo[bufnr].filetype == 'bigfile' then
        return
      end
      if path ~= vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr)) then
        return
      end
      local stat = vim.uv.fs_stat(path)
      if not stat or stat.type == 'directory' or stat.size <= 0 then
        return
      end
      local size = stat.size
      if size > vim.g.bigfile_size_threshold then
        return 'bigfile'
      end
      local lines = vim.api.nvim_buf_line_count(bufnr)
      -- (size - lines) / lines: This gives the average length (i.e., average bytes) of the
      -- content per line, excluding the newline character
      return (size - lines) / lines > vim.g.bigfile_line_length_threshold and 'bigfile' or nil
    end,
  },
})
