-- -----------------------------------------------------------
-- Module definition and configuration
-- -----------------------------------------------------------
---@class Utils.runner
local M = {}

M.config = {
  build_dir = "build",
  build_gen = "Ninja",
  default_build_options = "-std=c++20",
  tmp_dir = vim.uv.os_uname().sysname == "Windows_NT" and os.getenv("TMP") or "/tmp",
}

-- -----------------------------------------------------------
-- Helper functions
-- -----------------------------------------------------------

--- Match project name from CMakeLists.txt
local function get_target_name()
  local cmakelists_path = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":h") .. "/CMakeLists.txt"
  if vim.fn.filereadable(cmakelists_path) == 0 then
    return nil
  end
  local content = table.concat(vim.fn.readfile(cmakelists_path), "\n")
  local target = string.match(content, "add_executable%(([^%s)]+)")
  return target
end

--- Execute a command in the terminal
local function run_in_terminal(cmd, close_on_exit)
  if not cmd or cmd == "" then
    vim.notify("No matching file format or command found", vim.log.levels.ERROR)
    return
  end
  require("toggleterm.terminal").Terminal
    :new({
      cmd = cmd,
      close_on_exit = close_on_exit or false,
      hidden = true,
    })
    :toggle()
end

-- -----------------------------------------------------------
-- Public API (for keybindings)
-- -----------------------------------------------------------

--- Compile and run
function M.build_and_run()
  vim.api.nvim_command("write")

  local ft = vim.bo.filetype
  -- local fname = vim.fn.expand("%:t")
  local fpath = vim.fn.expand("%:p:h")
  local fname_abs = vim.fn.expand("%:p")
  local fname_no_ext = vim.fn.expand("%:t:r")
  local platform = vim.uv.os_uname().sysname
  local cmd = ""

  if ft == "python" then
    cmd = ("uv run %s"):format(fname_abs)
  elseif ft == "c" or ft == "cpp" or ft == "cmake" then
    local target = get_target_name()
    if target then
      -- CMake project
      local run_path = ("%s/%s"):format(M.config.build_dir, target)
      local cmake_build_cmd = ("cmake --build %s --target %s"):format(M.config.build_dir, target)
      local cmake_configure_cmd = ""
      if vim.fn.isdirectory(M.config.build_dir) == 0 then
        cmake_configure_cmd = ("cmake -S %s -B %s -G %s -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=ON && "):format(
          fpath,
          M.config.build_dir,
          M.config.build_gen
        )
      end
      cmd = cmake_configure_cmd .. cmake_build_cmd .. " && " .. run_path
    else
      -- Compile single file
      local run_target = "run_" .. fname_no_ext
      local run_path = ""

      if platform == "Windows_NT" then
        run_path = M.config.tmp_dir .. "\\" .. run_target .. ".exe"
        cmd = ("g++ %s -o %s %s && %s"):format(M.config.default_build_options, run_path, fname_abs, run_path)
      elseif platform == "Linux" then
        run_path = M.config.tmp_dir .. "/" .. run_target
        cmd = ("g++ %s -o %s %s && %s"):format(M.config.default_build_options, run_path, fname_abs, run_path)
      end
    end
  -- elseif ft == "markdown" then
  --   vim.api.nvim_command("MarkdownPreview")
  --   return
  elseif ft == "yacc" then
    cmd = "bison " .. fname_abs
  end

  run_in_terminal(cmd)
end

--- Only run
function M.run()
  local ft = vim.bo.filetype
  local cmd = ""

  if ft == "python" then
    cmd = ("uv run %s"):format(vim.fn.expand("%:p"))
  elseif ft == "c" or ft == "cpp" or ft == "cmake" then
    local target = get_target_name()
    if target then
      cmd = ("%s/%s"):format(M.config.build_dir, target)
    else
      local run_target = "run_" .. vim.fn.expand("%:t:r")
      local platform = vim.uv.os_uname().sysname
      if platform == "Windows_NT" then
        cmd = M.config.tmp_dir .. "\\" .. run_target .. ".exe"
      elseif platform == "Linux" then
        cmd = M.config.tmp_dir .. "/" .. run_target
      end
    end
  else
    vim.notify("Running not supported for current file type ", vim.log.levels.WARN)
    return
  end

  run_in_terminal(cmd)
end

local _lazygit_term = nil

function M.lazygit()
  if vim.fn.executable("lazygit") ~= 1 then
    vim.notify("lazygit not found. Please install it first.", vim.log.levels.ERROR)
    return
  end
  if not _lazygit_term then
    local Terminal = require("toggleterm.terminal").Terminal
    _lazygit_term = Terminal:new({
      cmd = "lazygit",
      direction = "float",
      close_on_exit = true,
      float_opts = {
        height = math.floor(vim.o.lines * 0.9),
      },
      on_exit = function()
        _lazygit_term = nil
      end,
      on_open = function(term)
        vim.keymap.set("t", "<c-h>", function()
          term:toggle()
        end, { buffer = term.bufnr, silent = true })
      end,
    })
  end

  if _lazygit_term then
    _lazygit_term:toggle()
  end
end

return M
