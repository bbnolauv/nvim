---@class Utils.runner
local M = {}

local CONFIG = {
  default_build_options = '-std=c++20',
  tmp_dir = vim.uv.os_uname().sysname == 'Windows_NT' and os.getenv('TMP') or '/tmp',
}

local function run_in_terminal(cmd, close_on_exit)
  if not cmd or cmd == '' then
    vim.notify('No matching file format or command found', vim.log.levels.ERROR)
    return
  end
  require('toggleterm.terminal').Terminal
    :new({
      cmd = cmd,
      close_on_exit = close_on_exit or false,
      hidden = true,
    })
    :toggle()
end

local function single_file_binary_path()
  local run_target = 'run_' .. vim.fn.expand('%:t:r')
  local platform = vim.uv.os_uname().sysname

  if platform == 'Windows_NT' then
    return CONFIG.tmp_dir .. '\\' .. run_target .. '.exe'
  end

  return CONFIG.tmp_dir .. '/' .. run_target
end

local function single_file_command()
  local ft = vim.bo.filetype
  local file_path = vim.fn.expand('%:p')

  if ft == 'python' then
    return ('uv run %s'):format(file_path)
  end

  if ft == 'c' or ft == 'cpp' then
    local binary_path = single_file_binary_path()
    return ('g++ %s -o %s %s && %s'):format(
      CONFIG.default_build_options,
      binary_path,
      file_path,
      binary_path
    )
  end

  if ft == 'yacc' then
    return ('bison %s'):format(file_path)
  end
end

function M.run_single_file()
  vim.cmd.write()

  local cmd = single_file_command()
  if not cmd then
    vim.notify('Running not supported for current file type', vim.log.levels.WARN)
    return
  end

  run_in_terminal(cmd)
end

local lazygit_term = nil

function M.lazygit()
  if vim.fn.executable('lazygit') ~= 1 then
    vim.notify('lazygit not found. Please install it first.', vim.log.levels.ERROR)
    return
  end
  if not lazygit_term then
    local Terminal = require('toggleterm.terminal').Terminal
    lazygit_term = Terminal:new({
      cmd = 'lazygit',
      direction = 'float',
      close_on_exit = true,
      float_opts = {
        height = math.floor(vim.o.lines * 0.9),
      },
      on_exit = function()
        lazygit_term = nil
      end,
      on_open = function(term)
        vim.keymap.set('t', '<c-h>', function()
          term:toggle()
        end, { buffer = term.bufnr, silent = true })
      end,
    })
  end

  lazygit_term:toggle()
end

return M
