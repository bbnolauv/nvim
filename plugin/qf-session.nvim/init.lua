if not vim.tbl_contains(vim.opt.sessionoptions:get(), 'globals') then
  vim.opt.sessionoptions:append('globals')
end

local function normalize_qf_items(items)
  local normalized = vim.deepcopy(items)
  for _, item in ipairs(normalized) do
    if item.bufnr and item.bufnr > 0 then
      local bufname = vim.api.nvim_buf_get_name(item.bufnr)
      if bufname ~= '' then
        item.filename = vim.fn.fnamemodify(bufname, ':p')
      end
      item.bufnr = nil
    elseif item.filename and item.filename ~= '' then
      item.filename = vim.fn.fnamemodify(item.filename, ':p')
    end
  end
  return normalized
end

vim.api.nvim_create_user_command('MkSessionPro', function(opts)
  local session_file = opts.args ~= '' and opts.args or 'Session.vim'
  local qf_data = vim.fn.getqflist({ items = 0, title = 0, idx = 0, winid = 0 })

  local qf_was_open = qf_data.winid ~= 0
  local qf_height = nil
  if qf_was_open and vim.api.nvim_win_is_valid(qf_data.winid) then
    qf_height = vim.api.nvim_win_get_height(qf_data.winid)
  end

  if qf_data.items and #qf_data.items > 0 then
    local payload = {
      title = qf_data.title,
      idx = qf_data.idx,
      items = normalize_qf_items(qf_data.items),
      open = qf_was_open,
    }
    if qf_height then
      payload.height = qf_height
    end
    vim.g.SavedQfList = vim.fn.json_encode(payload)
  else
    vim.g.SavedQfList = nil
  end

  if qf_was_open then
    vim.cmd.cclose()
  end

  if opts.bang then
    vim.cmd('mksession! ' .. vim.fn.fnameescape(session_file))
  else
    vim.cmd('mksession ' .. vim.fn.fnameescape(session_file))
  end

  if qf_was_open then
    if qf_height and qf_height > 0 then
      vim.cmd(('copen %d'):format(qf_height))
    else
      vim.cmd.copen()
    end
  end

  print('Session and quickfix list saved to ' .. session_file)
end, { nargs = '?', bang = true })

local qf_restore_group = vim.api.nvim_create_augroup('RestoreQuickfixSession', { clear = true })

vim.api.nvim_create_autocmd('SessionLoadPost', {
  group = qf_restore_group,
  pattern = '*',
  callback = function()
    if vim.g.SavedQfList then
      local ok, qf_data = pcall(vim.fn.json_decode, vim.g.SavedQfList)

      if ok and type(qf_data) == 'table' then
        vim.fn.setqflist({}, 'r', {
          title = qf_data.title,
          idx = qf_data.idx,
          items = qf_data.items or {},
        })

        if qf_data.open then
          vim.schedule(function()
            local height = tonumber(qf_data.height)
            if height and height > 0 then
              vim.cmd(('copen %d'):format(height))
            else
              vim.cmd.copen()
            end
          end)
        end

        print('Quickfix list restored from session.')
      end

      vim.g.SavedQfList = nil
    end
  end,
})
